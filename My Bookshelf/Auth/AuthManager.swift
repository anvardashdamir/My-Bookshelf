//
//  AuthManager.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 14.11.25.
//

import Foundation
import FirebaseAuth


final class AuthManager {

    static let shared = AuthManager()

    private let usersKey = "registered_users"
    private let currentUserKey = "current_user_email"
    

    private init() {}
    
    // MARK: - Public Properties
    var currentUserEmail: String? {
        KeychainHelper.shared.load(key: currentUserKey)
    }
    

    var isLoggedIn: Bool {
        // Check Firebase Auth first (primary authentication)
        // OR check Keychain (backward compatibility for old users)
        Auth.auth().currentUser != nil || currentUserEmail != nil
    }
    

    func register(email: String, password: String) async throws {
        // Normalize email: convert to lowercase for consistency
        let cleanedEmail = email.lowercased()
        
        // Create Firebase Auth user
        do {
            // await: Pauses here until Firebase responds (non-blocking)
            // Creates user in Firebase Authentication (visible in Firebase Console)
            let authResult = try await Auth.auth().createUser(withEmail: cleanedEmail, password: password)
            print("Firebase Auth user created: \(authResult.user.uid)")
            
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
    

    func login(email: String, password: String) async throws {
        let cleanedEmail = email.lowercased()
        
        // Sign in with Firebase Auth
        do {
            // await: Waits for Firebase to validate credentials
            // Returns AuthResult containing user info if successful
            let authResult = try await Auth.auth().signIn(withEmail: cleanedEmail, password: password)
            print("Firebase Auth sign in successful: \(authResult.user.uid)")
            
            // Also save to local Keychain for backward compatibility
            _ = KeychainHelper.shared.save(key: currentUserKey, value: cleanedEmail)
        } catch {
            // Error handling: Convert Firebase error codes to our custom errors
            if let nsError = error as NSError?,
               nsError.domain == "FIRAuthErrorDomain" {
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
    
 
    func logout() throws {
        // Sign out from Firebase Auth (clears currentUser)
        try Auth.auth().signOut()
        // Remove email from Keychain
        _ = KeychainHelper.shared.delete(key: currentUserKey)
    }
    

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
    

    private func loadUsers() -> [String: String] {
        // ?? [:] means "if nil, use empty dictionary instead"
        KeychainHelper.shared.loadDictionary(key: usersKey) ?? [:]
    }
    

    private func saveUsers(_ users: [String: String]) {
        _ = KeychainHelper.shared.saveDictionary(key: usersKey, dictionary: users)
    }
}

enum AuthError: LocalizedError {
 
    case emailAlreadyInUse
    case userNotFound
    case invalidPassword
    

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
