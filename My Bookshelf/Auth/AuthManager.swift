//
//  AuthManager.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 14.11.25.
//

import Foundation
import FirebaseAuth

/**
 * AuthManager: Singleton class that manages user authentication
 *
 * RESPONSIBILITIES:
 * - Handles user registration (creates Firebase Auth users)
 * - Handles user login (signs in with Firebase Auth)
 * - Handles user logout (signs out from Firebase Auth)
 * - Handles account deletion (deletes Firebase Auth user)
 * - Maintains backward compatibility with local Keychain storage
 *
 * DESIGN PATTERN: Singleton - only one instance exists (shared)
 * WHY: Ensures consistent authentication state across the entire app
 */
final class AuthManager {

    static let shared = AuthManager()
    
    /**
     * PRIVATE CONSTANTS: Keys for Keychain storage
     * - usersKey: Stores dictionary of all registered users (email -> password)
     * - currentUserKey: Stores the email of the currently logged-in user
     */
    private let usersKey = "registered_users"
    private let currentUserKey = "current_user_email"
    
    /**
     * PRIVATE INIT: Prevents creating new instances
     * Only AuthManager.shared can be used - enforces singleton pattern
     */
    private init() {}
    
    // MARK: - Public Properties
    
    /**
     * Computed property: Gets the current user's email from Keychain
     * Returns: Optional String - email if logged in, nil otherwise
     * HOW IT WORKS: Reads from secure Keychain storage using the currentUserKey
     */
    var currentUserEmail: String? {
        KeychainHelper.shared.load(key: currentUserKey)
    }
    
    /**
     * Computed property: Checks if user is logged in
     * Returns: Bool - true if Firebase Auth has a current user OR Keychain has email
     * WHY BOTH CHECKS: Backward compatibility - old users might only have Keychain data
     */
    var isLoggedIn: Bool {
        // Check Firebase Auth first (primary authentication)
        // OR check Keychain (backward compatibility for old users)
        Auth.auth().currentUser != nil || currentUserEmail != nil
    }
    
    /**
     * Registers a new user with Firebase Authentication
     *
     * PARAMETERS:
     * - email: User's email address (will be lowercased)
     * - password: User's password (must be at least 6 characters)
     *
     * RETURNS: Nothing (async throws - can throw errors)
     *
     * WHAT IT DOES:
     * 1. Lowercases email for consistency
     * 2. Creates Firebase Auth user (stored in Firebase Console)
     * 3. Saves to local Keychain for backward compatibility
     * 4. Handles errors (email already exists, weak password, etc.)
     *
     * async: Function can be paused while waiting for Firebase response
     * throws: Can throw errors that caller must handle with try/catch
     */
    func register(email: String, password: String) async throws {
        // Normalize email: convert to lowercase for consistency
        let cleanedEmail = email.lowercased()
        
        // Create Firebase Auth user
        do {
            // await: Pauses here until Firebase responds (non-blocking)
            // Creates user in Firebase Authentication (visible in Firebase Console)
            let authResult = try await Auth.auth().createUser(withEmail: cleanedEmail, password: password)
            print("✅ Firebase Auth user created: \(authResult.user.uid)")
            
            // Also save to local Keychain for backward compatibility
            // This allows old code that checks Keychain to still work
            var users = loadUsers() // Get existing users dictionary
            users[cleanedEmail] = password // Add new user to dictionary
            saveUsers(users) // Save updated dictionary back to Keychain
            _ = KeychainHelper.shared.save(key: currentUserKey, value: cleanedEmail)
        } catch {
            // Error handling: Convert Firebase errors to our custom AuthError enum
            if let nsError = error as NSError?,
               nsError.domain == "FIRAuthErrorDomain",
               nsError.code == 17007 { // Firebase error code for "email already in use"
                throw AuthError.emailAlreadyInUse // Throw our custom error
            }
            // If it's a different error, re-throw it as-is
            throw error
        }
    }
    
    /**
     * Logs in an existing user with Firebase Authentication
     *
     * PARAMETERS:
     * - email: User's email address
     * - password: User's password
     *
     * RETURNS: Nothing (async throws)
     *
     * WHAT IT DOES:
     * 1. Signs in with Firebase Auth (validates credentials)
     * 2. Saves email to Keychain for backward compatibility
     * 3. Converts Firebase errors to user-friendly AuthError enum
     */
    func login(email: String, password: String) async throws {
        let cleanedEmail = email.lowercased()
        
        // Sign in with Firebase Auth
        do {
            // await: Waits for Firebase to validate credentials
            // Returns AuthResult containing user info if successful
            let authResult = try await Auth.auth().signIn(withEmail: cleanedEmail, password: password)
            print("✅ Firebase Auth sign in successful: \(authResult.user.uid)")
            
            // Also save to local Keychain for backward compatibility
            _ = KeychainHelper.shared.save(key: currentUserKey, value: cleanedEmail)
        } catch {
            // Error handling: Convert Firebase error codes to our custom errors
            if let nsError = error as NSError?,
               nsError.domain == "FIRAuthErrorDomain" {
                // switch: Pattern matching on error code
                switch nsError.code {
                case 17011: // Firebase error: User not found
                    throw AuthError.userNotFound
                case 17009, 17010: // Firebase errors: Wrong password
                    throw AuthError.invalidPassword
                default:
                    // Unknown Firebase error - re-throw as-is
                    throw error
                }
            }
            throw error
        }
    }
    
    /**
     * Logs out the current user
     *
     * WHAT IT DOES:
     * 1. Signs out from Firebase Auth
     * 2. Removes email from Keychain
     *
     * throws: Can throw if signOut fails (rare)
     */
    func logout() throws {
        // Sign out from Firebase Auth (clears currentUser)
        try Auth.auth().signOut()
        // Remove email from Keychain
        _ = KeychainHelper.shared.delete(key: currentUserKey)
    }
    
    /**
     * Permanently deletes the user's account
     *
     * WHAT IT DOES:
     * 1. Deletes Firebase Auth user (removes from Firebase Console)
     * 2. Removes user from local Keychain storage
     * 3. Clears current user email
     *
     * async: Waits for Firebase to delete the user
     * throws: Can throw if no user is logged in or deletion fails
     */
    func deleteAccount() async throws {
        // guard: Early exit if condition fails (throws error)
        // Ensures we have a logged-in user before attempting deletion
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        // Delete Firebase Auth user (permanent - cannot be undone)
        // await: Waits for Firebase to complete deletion
        try await user.delete()
        
        // Also clean up local storage
        if let email = currentUserEmail {
            var users = loadUsers() // Get dictionary of all users
            users.removeValue(forKey: email.lowercased()) // Remove this user
            saveUsers(users) // Save updated dictionary
        }
        
        // Clear current user email from Keychain
        _ = KeychainHelper.shared.delete(key: currentUserKey)
    }
        
    // MARK: - Private Helper Methods
    
    /**
     * Loads all registered users from Keychain
     * Returns: Dictionary mapping email -> password
     *          Empty dictionary [:] if nothing found (nil coalescing ??)
     */
    private func loadUsers() -> [String: String] {
        // Dictionary type: [String: String] means keys are Strings, values are Strings
        // ?? [:] means "if nil, use empty dictionary instead"
        KeychainHelper.shared.loadDictionary(key: usersKey) ?? [:]
    }
    
    /**
     * Saves all registered users to Keychain
     * PARAMETER: users - Dictionary of email -> password mappings
     */
    private func saveUsers(_ users: [String: String]) {
        // _ = ignores return value (we don't need to check if save succeeded)
        _ = KeychainHelper.shared.saveDictionary(key: usersKey, dictionary: users)
    }
}

/**
 * AuthError: Custom error enum for authentication errors
 *
 * WHAT IT IS: An enumeration (enum) - a type with predefined cases
 * WHY USE IT: Provides type-safe, user-friendly error messages
 *
 * LocalizedError: Protocol that allows errors to provide localized descriptions
 *                 (iOS can show these to users in their language)
 */
enum AuthError: LocalizedError {
    /**
     * ENUM CASES: The possible authentication errors
     * - emailAlreadyInUse: User tried to register with existing email
     * - userNotFound: User tried to login with non-existent email
     * - invalidPassword: User entered wrong password
     */
    case emailAlreadyInUse
    case userNotFound
    case invalidPassword
    
    /**
     * Computed property: Returns user-friendly error message
     * WHAT IT DOES: Converts enum case to readable String
     * 
     * switch self: Pattern matching - checks which case this is
     * Returns: Optional String - message for that error case
     */
    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .userNotFound:
            return "No user found with this email."
        case .invalidPassword:
            return "Incorrect password."
        }
    }
}
