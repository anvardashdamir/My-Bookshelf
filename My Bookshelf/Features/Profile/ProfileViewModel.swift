//
//  ProfileViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import UIKit
import Foundation

struct ProfileViewData {
    let name: String
    let email: String
    let image: UIImage?
}


final class ProfileViewModel {
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager = .shared) {
           self.authManager = authManager
       }

    var userName: String {
        ProfileManager.shared.userName
    }

    var userEmail: String {
        ProfileManager.shared.userEmail
    }

    var profileImage: UIImage? {
        ProfileManager.shared.profilePhoto
    }

    func logout() throws {
        try AuthManager.shared.logout()
    }
    
    func loadProfile() -> ProfileViewData {
           let email = authManager.currentUserEmail ?? "Unknown"

           return ProfileViewData(
               name: email.components(separatedBy: "@").first?.capitalized ?? "User",
               email: email,
               image: loadProfileImage()
           )
       }

    func deleteAccount() async throws {
        authManager.deleteAccount()
    }
    
    private func loadProfileImage() -> UIImage? {
          // Placeholder for now
          UIImage(systemName: "person.circle.fill")
      }

    func updateProfile(
        name: String?,
        email: String?,
        photo: UIImage?
    ) {
        ProfileManager.shared.updateProfile(
            name: name,
            email: email,
            photo: photo
        )
    }
}
