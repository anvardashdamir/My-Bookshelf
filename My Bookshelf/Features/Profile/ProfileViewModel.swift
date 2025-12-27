//
//  ProfileViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.11.25.
//

import UIKit
import FirebaseAuth

final class ProfileViewModel {
    
    // MARK: - Dependencies
    
    private let profileManager = ProfileManager.shared
    private let authManager = AuthManager.shared
    
    // MARK: - Published Properties
    
    var userName: String {
        profileManager.userName
    }
    
    var userEmail: String {
        profileManager.userEmail
    }
    
    var profilePhoto: UIImage? {
        profileManager.profilePhoto
    }
    
    var isDarkModeEnabled: Bool {
        if let savedStyle = UserDefaults.standard.string(forKey: "userInterfaceStyle") {
            return savedStyle == "dark"
        }
        return false
    }
    
    // MARK: - Callbacks
    
    var onProfileUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLogoutSuccess: (() -> Void)?
    var onDeleteAccountSuccess: (() -> Void)?
    
    // MARK: - Public Methods
    
    func loadProfile() {
        onProfileUpdated?()
    }
    
    func updateProfile(name: String?, email: String?, photo: UIImage?) {
        profileManager.updateProfile(name: name, email: email, photo: photo)
        onProfileUpdated?()
    }
    
    func updateDarkMode(isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled ? "dark" : "light", forKey: "userInterfaceStyle")
        
        let style: UIUserInterfaceStyle = isEnabled ? .dark : .light
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        }
    }
    
    func logout() {
        do {
            try authManager.logout()
            onLogoutSuccess?()
        } catch {
            onError?("Failed to log out: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        Task {
            do {
                try await authManager.deleteAccount()
                await MainActor.run {
                    self.onDeleteAccountSuccess?()
                }
            } catch {
                await MainActor.run {
                    self.onError?("Failed to delete account: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func processSelectedImage(_ image: UIImage) {
        updateProfile(name: nil, email: nil, photo: image)
        
        Task {
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
        }
    }
}

