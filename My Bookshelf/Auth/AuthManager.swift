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
    
    // MARK: - Public
    var currentUserEmail: String? {
        KeychainHelper.shared.load(key: currentUserKey)
    }
    
    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil || currentUserEmail != nil
    }
    
    func register(email: String, password: String) async throws {
        let cleanedEmail = email.lowercased()
        
        // Create Firebase Auth user
        do {
            let authResult = try await Auth.auth().createUser(withEmail: cleanedEmail, password: password)
            print("✅ Firebase Auth user created: \(authResult.user.uid)")
            
            // Also save to local Keychain for backward compatibility
            var users = loadUsers()
            users[cleanedEmail] = password
            saveUsers(users)
            _ = KeychainHelper.shared.save(key: currentUserKey, value: cleanedEmail)
        } catch {
            // Check if email already exists in Firebase
            if let nsError = error as NSError?,
               nsError.domain == "FIRAuthErrorDomain",
               nsError.code == 17007 { // Email already in use
                throw AuthError.emailAlreadyInUse
            }
            throw error
        }
    }
    
    func login(email: String, password: String) async throws {
        let cleanedEmail = email.lowercased()
        
        // Sign in with Firebase Auth
        do {
            let authResult = try await Auth.auth().signIn(withEmail: cleanedEmail, password: password)
            print("✅ Firebase Auth sign in successful: \(authResult.user.uid)")
            
            // Also save to local Keychain for backward compatibility
            _ = KeychainHelper.shared.save(key: currentUserKey, value: cleanedEmail)
        } catch {
            // Check for specific Firebase Auth errors
            if let nsError = error as NSError?,
               nsError.domain == "FIRAuthErrorDomain" {
                switch nsError.code {
                case 17011: // User not found
                    throw AuthError.userNotFound
                case 17009, 17010: // Wrong password
                    throw AuthError.invalidPassword
                default:
                    throw error
                }
            }
            throw error
        }
    }
    
    func logout() throws {
        try Auth.auth().signOut()
        _ = KeychainHelper.shared.delete(key: currentUserKey)
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        // Delete Firebase Auth user
        try await user.delete()
        
        // Also clean up local storage
        if let email = currentUserEmail {
            var users = loadUsers()
            users.removeValue(forKey: email.lowercased())
            saveUsers(users)
        }
        
        // Clear current user
        _ = KeychainHelper.shared.delete(key: currentUserKey)
    }
        
    // MARK: - Private
    private func loadUsers() -> [String: String] {
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
