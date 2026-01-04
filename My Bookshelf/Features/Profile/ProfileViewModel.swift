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
    
    func loadProfileFromFirebase() async throws {
        guard let userId = authManager.currentUserId else {
            print("⚠️ No user ID available to load profile")
            return
        }
        
        print("🔄 Loading profile from Firebase for user: \(userId)")
        let profile = try await FirebaseProfileService.shared.fetchProfile(userId: userId)
        
        ProfileManager.shared.updateProfile(
            name: profile.name,
            email: profile.email,
            photo: nil
        )
        
        if let photoURL = profile.photoURL {
            do {
                let image = try await FirebaseProfileService.shared.fetchProfilePhoto(urlString: photoURL)
                if let image = image {
                    ProfileManager.shared.updateProfile(name: nil, email: nil, photo: image)
                }
            } catch {
                print("⚠️ Could not load profile photo: \(error.localizedDescription)")
            }
        }
        
        print("✅ Profile loaded from Firebase: \(profile.name) - \(profile.email)")
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

    func deleteAccount(passwordForReauth: String?) async throws {
        try await authManager.deleteAccount(passwordForReauth: passwordForReauth)
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
