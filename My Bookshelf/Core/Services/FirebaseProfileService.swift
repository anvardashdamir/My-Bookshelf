//
//  FirebaseProfileService.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.11.25.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

final class FirebaseProfileService {
    static let shared = FirebaseProfileService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    // MARK: - Profile Data
    
    func fetchProfile(userId: String) async throws -> UserProfile {
        let docRef = db.collection("users")
            .document(userId)
            .collection("data")
            .document("profile")
        
        let doc = try await docRef.getDocument()
        
        if doc.exists {
            return try doc.data(as: UserProfile.self)
        } else {
            // Return default profile
            return UserProfile(name: "John Smith", email: "", photoURL: nil)
        }
    }
    
    func saveProfile(_ profile: UserProfile, userId: String) async throws {
        try db.collection("users")
            .document(userId)
            .collection("data")
            .document("profile")
            .setData(from: profile)
    }
    
    // MARK: - Profile Photo
    
    func uploadProfilePhoto(_ image: UIImage, userId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw FirebaseProfileError.imageConversionFailed
        }
        
        // Verify user is authenticated
        guard let currentUserId = FirebaseAuthService.shared.currentUserId else {
            throw FirebaseProfileError.uploadFailed(underlyingError: NSError(
                domain: "FirebaseProfileService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            ))
        }
        
        guard currentUserId == userId else {
            throw FirebaseProfileError.uploadFailed(underlyingError: NSError(
                domain: "FirebaseProfileService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "User ID mismatch"]
            ))
        }
        
        let photoRef = storage.reference()
            .child("users")
            .child(userId)
            .child("profile_photo.jpg")
        
        print("📤 Uploading profile photo to: users/\(userId)/profile_photo.jpg")
        print("   Image size: \(imageData.count) bytes")
        print("   User ID: \(userId)")
        print("   Authenticated User ID: \(currentUserId)")
        
        // Add metadata for better compatibility
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.cacheControl = "public,max-age=3600"
        
        do {
            // Upload the data
            let uploadTask = photoRef.putData(imageData, metadata: metadata)
            _ = try await uploadTask
            print("✅ File uploaded, getting download URL...")
            
            // Get download URL
            let downloadURL = try await photoRef.downloadURL()
            print("✅ Profile photo uploaded successfully: \(downloadURL.absoluteString)")
            return downloadURL.absoluteString
        } catch {
            print("❌ Firebase Storage upload error:")
            print("   Error: \(error)")
            print("   Localized: \(error.localizedDescription)")
            print("   Error Type: \(type(of: error))")
            
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
                
                // Check for specific Firebase Storage error codes
                if nsError.domain.contains("FIRStorage") || nsError.domain.contains("Storage") {
                    print("   This is a Firebase Storage error")
                    
                    // Common error codes:
                    // -13010: Object does not exist (usually means permission denied)
                    // -13020: Unauthorized
                    // -13021: Quota exceeded
                    if nsError.code == -13010 {
                        print("   ⚠️ Error -13010: This usually means permission denied!")
                        print("   Check Firebase Storage security rules!")
                    }
                }
            }
            
            // Re-throw with more context
            throw FirebaseProfileError.uploadFailed(underlyingError: error)
        }
    }
    
    func fetchProfilePhoto(urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
    
    func deleteProfilePhoto(userId: String) async throws {
        let photoRef = storage.reference()
            .child("users")
            .child(userId)
            .child("profile_photo.jpg")
        
        try await photoRef.delete()
    }
}

struct UserProfile: Codable {
    var name: String
    var email: String
    var photoURL: String?
}

enum FirebaseProfileError: LocalizedError {
    case imageConversionFailed
    case uploadFailed(underlyingError: Error)
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to data."
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .uploadFailed(let error):
            return error
        default:
            return nil
        }
    }
}

