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

    private init() {}

    // MARK: - State
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    var currentUserId: String? {
        currentUser?.uid
    }
    
    var currentUserEmail: String? {
        currentUser?.email
    }

    var isLoggedIn: Bool {
        currentUser != nil
    }

    // MARK: - Actions
    func register(email: String, password: String) async throws {
        let cleanedEmail = email.lowercased()
        do {
            let authResult = try await Auth.auth().createUser(withEmail: cleanedEmail, password: password)
            print("✅ Firebase Auth user created: \(authResult.user.uid)")
        } catch {
            if let nsError = error as NSError?,
               nsError.domain == "FIRAuthErrorDomain",
               nsError.code == 17007 {
                throw AuthError.emailAlreadyInUse
            }
            throw error
        }
    }

    func login(email: String, password: String) async throws {
        let cleanedEmail = email.lowercased()
        do {
            let authResult = try await Auth.auth().signIn(withEmail: cleanedEmail, password: password)
            print("✅ Firebase Auth login successful: \(authResult.user.uid)")
        } catch {
            if let nsError = error as NSError?,
               nsError.domain == "FIRAuthErrorDomain" {
                switch nsError.code {
                case 17011:
                    throw AuthError.userNotFound
                case 17009:
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
        print("✅ Firebase Auth logout successful")
        clearUserData()
    }
    
    private func clearUserData() {
        ProfileManager.shared.clearProfile()
        ListsManager.shared.clearAllLists()
        RecentlyViewedStore.shared.clearAll()
        print("✅ All user data cleared (profile, lists, recently viewed)")
    }

    func deleteAccount(passwordForReauth: String?) async throws {
        guard let user = currentUser else {
            throw AuthError.userNotFound
        }
        
        let userId = user.uid
        
        // First delete all Firestore data
        try await FirebaseUserDataService.shared.deleteAllUserData(userId: userId)
        
        // Then delete Firebase Auth user
        do {
            try await user.delete()
            print("✅ Firebase Auth account deleted")
        } catch {
            // Check if error is requiresRecentLogin
            if let nsError = error as NSError?,
               nsError.domain == "FIRAuthErrorDomain",
               nsError.code == 17014 {
                // Requires recent login - need to reauthenticate
                guard let password = passwordForReauth else {
                    throw AuthError.requiresRecentLogin
                }
                
                // Reauthenticate with email and password
                guard let email = user.email else {
                    throw AuthError.userNotFound
                }
                
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                try await user.reauthenticate(with: credential)
                print("✅ Reauthentication successful")
                
                // Retry delete after reauthentication
                try await user.delete()
                print("✅ Firebase Auth account deleted after reauthentication")
            } else {
                throw error
            }
        }
        
        // Finally clear local data
        clearUserData()
    }
}

enum AuthError: LocalizedError {
    case emailAlreadyInUse
    case userNotFound
    case invalidPassword
    case requiresRecentLogin
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .userNotFound:
            return "No user found with this email."
        case .invalidPassword:
            return "Incorrect password."
        case .requiresRecentLogin:
            return "For security, please enter your password to confirm account deletion."
        }
    }
}
