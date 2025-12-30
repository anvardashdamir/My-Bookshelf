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

    // MARK: - State
    var currentUserEmail: String? {
        KeychainHelper.shared.load(key: currentUserKey)
    }

    var isLoggedIn: Bool {
        currentUserEmail != nil
    }

    // MARK: - Actions
    func register(email: String, password: String) throws {
        var users = loadUsers()
        let email = email.lowercased()

        guard users[email] == nil else {
            throw AuthError.emailAlreadyInUse
        }

        users[email] = password
        saveUsers(users)
        setCurrentUser(email)
    }

    func login(email: String, password: String) throws {
        let users = loadUsers()
        let email = email.lowercased()

        guard let storedPassword = users[email] else {
            throw AuthError.userNotFound
        }

        guard storedPassword == password else {
            throw AuthError.invalidPassword
        }

        setCurrentUser(email)
    }

    func logout() {
        clearCurrentUser()
    }

    func deleteAccount() {
        guard let email = currentUserEmail else { return }

        var users = loadUsers()
        users.removeValue(forKey: email.lowercased())
        saveUsers(users)
        clearCurrentUser()
    }

    // MARK: - Private helpers
    private func setCurrentUser(_ email: String) {
        _ = KeychainHelper.shared.save(key: currentUserKey, value: email)
    }

    private func clearCurrentUser() {
        _ = KeychainHelper.shared.delete(key: currentUserKey)
    }

    private func loadUsers() -> [String: String] {
        KeychainHelper.shared.loadDictionary(key: usersKey) ?? [:]
    }

    private func saveUsers(_ users: [String: String]) {
        _ = KeychainHelper.shared.saveDictionary(
            key: usersKey,
            dictionary: users
        )
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
