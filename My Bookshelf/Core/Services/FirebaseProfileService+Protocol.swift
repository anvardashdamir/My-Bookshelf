//
//  FirebaseProfileService+Protocol.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import Foundation

extension FirebaseProfileService: FirebaseProfileServiceProtocol {
    func loadProfile(userId: String) async throws -> UserProfileData {
        let profile = try await fetchProfile(userId: userId)
        return UserProfileData(
            name: profile.name,
            email: profile.email,
            photoURL: profile.photoURL
        )
    }
    
    func loadProfilePhotoData(urlString: String) async throws -> Data? {
        return try await fetchProfilePhoto(urlString: urlString)
    }
}
