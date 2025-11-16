//
//  AuthManager.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 14.11.25.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    private let usersKey = "registered_users"
    private let currentUserKey = "current_user_email"
    
    private init() {}
    
    // MARK: - Public
    
    var currentUserEmail: String? {
        UserDefaults.standard.string(forKey: currentUserKey)
    }
    
    var isLoggedIn: Bool {
        currentUserEmail != nil
    }
    
    func register(email: String, password: String) throws {
        var users = loadUsers()
        let cleanedEmail = email.lowercased()
        
        guard users[cleanedEmail] == nil else {
            throw AuthError.emailAlreadyInUse
        }
        
        users[cleanedEmail] = password
        saveUsers(users)
        UserDefaults.standard.set(cleanedEmail, forKey: currentUserKey)
    }
    
    func login(email: String, password: String) throws {
        let users = loadUsers()
        let cleanedEmail = email.lowercased()
        
        guard let storedPassword = users[cleanedEmail] else {
            throw AuthError.userNotFound
        }
        
        guard storedPassword == password else {
            throw AuthError.invalidPassword
        }
        
        UserDefaults.standard.set(cleanedEmail, forKey: currentUserKey)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    // MARK: - Private
    
    private func loadUsers() -> [String: String] {
        (UserDefaults.standard.dictionary(forKey: usersKey) as? [String: String]) ?? [:]
    }
    
    private func saveUsers(_ users: [String: String]) {
        UserDefaults.standard.set(users, forKey: usersKey)
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
