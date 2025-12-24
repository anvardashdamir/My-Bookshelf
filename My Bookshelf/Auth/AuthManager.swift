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
        KeychainHelper.shared.load(key: currentUserKey)
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
        _ = KeychainHelper.shared.save(key: currentUserKey, value: cleanedEmail)
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
        
        _ = KeychainHelper.shared.save(key: currentUserKey, value: cleanedEmail)
    }
    
    func logout() {
        _ = KeychainHelper.shared.delete(key: currentUserKey)
    }
    
    func deleteAccount() {
        guard let email = currentUserEmail else { return }
        
        // Remove user from registered users
        var users = loadUsers()
        users.removeValue(forKey: email.lowercased())
        saveUsers(users)
        
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
