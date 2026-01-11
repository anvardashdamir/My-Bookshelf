//
//  FirebaseProfileServiceProtocol.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import Foundation

struct UserProfileData {
    let name: String
    let email: String
    let photoURL: String?
}

protocol FirebaseProfileServiceProtocol {
    func loadProfile(userId: String) async throws -> UserProfileData
    func loadProfilePhotoData(urlString: String) async throws -> Data?
}
