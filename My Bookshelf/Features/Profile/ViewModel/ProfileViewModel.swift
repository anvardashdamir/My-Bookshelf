//
//  ProfileViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import Foundation

final class ProfileViewModel {
    
    private let authManager: AuthManagerProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let firebaseProfileService: FirebaseProfileServiceProtocol
    
    init(
        authManager: AuthManagerProtocol,
        profileRepository: ProfileRepositoryProtocol,
        firebaseProfileService: FirebaseProfileServiceProtocol
    ) {
        self.authManager = authManager
        self.profileRepository = profileRepository
        self.firebaseProfileService = firebaseProfileService
    }

    var userName: String {
        profileRepository.userName
    }

    var userEmail: String {
        profileRepository.userEmail
    }

    var profileImageData: Data? {
        profileRepository.profileImageData
    }
    
    func loadProfileFromFirebase() async throws {
        guard let userId = authManager.currentUserId else {
            print("⚠️ No user ID available to load profile")
            throw NSError(domain: "ProfileViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user ID available"])
        }
        
        print("🔄 Loading profile from Firebase for user: \(userId)")
        let profile = try await firebaseProfileService.loadProfile(userId: userId)
        
        // Update repository (single source of truth)
        profileRepository.updateProfile(
            name: profile.name,
            email: profile.email,
            photoData: nil
        )
        
        // Load and store photo if URL exists
        if let photoURL = profile.photoURL {
            do {
                if let photoData = try await firebaseProfileService.loadProfilePhotoData(urlString: photoURL) {
                    profileRepository.updateProfile(name: nil, email: nil, photoData: photoData)
                }
            } catch {
                print("⚠️ Could not load profile photo: \(error.localizedDescription)")
            }
        }
        
        print("✅ Profile loaded from Firebase: \(profile.name) - \(profile.email)")
    }

    func logout() throws {
        try authManager.logout()
    }
    
    func deleteAccount(passwordForReauth: String?) async throws {
        try await authManager.deleteAccount(passwordForReauth: passwordForReauth)
    }

    func updateProfile(
        name: String?,
        email: String?,
        photoData: Data?
    ) {
        profileRepository.updateProfile(
            name: name,
            email: email,
            photoData: photoData
        )
    }
}
