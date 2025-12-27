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
import FirebaseAuth

/**
 * FirebaseProfileService: Handles all Firebase operations for user profiles
 *
 * RESPONSIBILITIES:
 * - Saves/fetches user profile data to/from Firestore
 * - Uploads/downloads profile photos to/from Firebase Storage
 * - Manages user-specific data in Firebase
 *
 * FIRESTORE STRUCTURE:
 *   users/
 *     {userId}/
 *       data/
 *         profile/  (document with name, email, photoURL)
 *
 * STORAGE STRUCTURE:
 *   users/
 *     {userId}/
 *       profile_photo.jpg
 *
 * DESIGN PATTERN: Singleton - one shared instance
 */
final class FirebaseProfileService {
    /**
     * Singleton instance
     */
    static let shared = FirebaseProfileService()
    
    /**
     * FIRESTORE INSTANCE: Database for storing structured data (JSON-like)
     * - db: Reference to Firestore database
     */
    private let db = Firestore.firestore()
    
    /**
     * STORAGE INSTANCE: Cloud storage for files (images, videos, etc.)
     * - storage: Reference to Firebase Storage
     */
    private let storage = Storage.storage()
    
    /**
     * Private init: Enforces singleton pattern
     */
    private init() {}
    
    // MARK: - Profile Data Methods (Firestore)
    
    /**
     * fetchProfile: Retrieves user profile from Firestore
     *
     * PARAMETER: userId - Firebase Auth user ID
     * RETURNS: UserProfile struct with name, email, photoURL
     *
     * FIRESTORE PATH: users/{userId}/data/profile
     * 
     * async: Can be paused while waiting for network response
     * throws: Can throw errors (network failure, permission denied, etc.)
     */
    func fetchProfile(userId: String) async throws -> UserProfile {
        /**
         * FIRESTORE PATH BUILDING:
         * - collection("users"): Top-level collection
         * - document(userId): User-specific document
         * - collection("data"): Sub-collection for user data
         * - document("profile"): Profile document
         */
        let docRef = db.collection("users")
            .document(userId)
            .collection("data")
            .document("profile")
        
        // await: Waits for Firestore to fetch document (non-blocking)
        let doc = try await docRef.getDocument()
        
        /**
         * CHECK IF DOCUMENT EXISTS:
         * - doc.exists: Bool indicating if document was found
         * - doc.data(as:): Converts Firestore data to Swift struct (using Codable)
         */
        if doc.exists {
            // Document exists - convert to UserProfile struct
            return try doc.data(as: UserProfile.self)
        } else {
            // Document doesn't exist - return default profile
            return UserProfile(name: "John Smith", email: "", photoURL: nil)
        }
    }
    
    /**
     * saveProfile: Saves user profile to Firestore
     *
     * PARAMETERS:
     * - profile: UserProfile struct to save
     * - userId: Firebase Auth user ID
     *
     * WHAT IT DOES:
     * 1. Converts UserProfile struct to Firestore format (using Codable)
     * 2. Saves to path: users/{userId}/data/profile
     * 3. Creates document if it doesn't exist, updates if it does
     *
     * setData(from:): Automatically converts Codable struct to Firestore format
     */
    func saveProfile(_ profile: UserProfile, userId: String) async throws {
        // Save profile to Firestore (creates or updates document)
        try db.collection("users")
            .document(userId)
            .collection("data")
            .document("profile")
            .setData(from: profile) // Codable conversion happens here
    }
    
    // MARK: - Profile Photo Methods (Firebase Storage)
    
    /**
     * uploadProfilePhoto: Uploads profile photo to Firebase Storage
     *
     * PARAMETERS:
     * - image: UIImage to upload
     * - userId: Firebase Auth user ID
     *
     * RETURNS: String - Download URL for the uploaded photo
     *
     * STORAGE PATH: users/{userId}/profile_photo.jpg
     *
     * WHAT IT DOES:
     * 1. Converts UIImage to JPEG data (80% quality)
     * 2. Verifies user is authenticated
     * 3. Verifies userId matches authenticated user (security)
     * 4. Uploads to Firebase Storage
     * 5. Gets download URL and returns it
     */
    func uploadProfilePhoto(_ image: UIImage, userId: String) async throws -> String {
        /**
         * STEP 1: Convert UIImage to JPEG data
         * - compressionQuality: 0.8 = 80% quality (good balance of size/quality)
         * - guard: Throws error if conversion fails
         */
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw FirebaseProfileError.imageConversionFailed
        }
        
        /**
         * STEP 2: Security check - verify user is authenticated
         * - Prevents unauthorized uploads
         */
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw FirebaseProfileError.uploadFailed(underlyingError: NSError(
                domain: "FirebaseProfileService",
                code: 401, // Unauthorized
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            ))
        }
        
        /**
         * STEP 3: Security check - verify userId matches authenticated user
         * - Prevents users from uploading to other users' folders
         */
        guard currentUserId == userId else {
            throw FirebaseProfileError.uploadFailed(underlyingError: NSError(
                domain: "FirebaseProfileService",
                code: 403, // Forbidden
                userInfo: [NSLocalizedDescriptionKey: "User ID mismatch"]
            ))
        }
        
        /**
         * STEP 4: Create Storage reference (path to file)
         * - reference(): Root of Storage
         * - child(): Navigate to subdirectory
         * - PATH: users/{userId}/profile_photo.jpg
         */
        let photoRef = storage.reference()
            .child("users")
            .child(userId)
            .child("profile_photo.jpg")
        
        print("📤 Uploading profile photo to: users/\(userId)/profile_photo.jpg")
        print("   Image size: \(imageData.count) bytes")
        print("   User ID: \(userId)")
        print("   Authenticated User ID: \(currentUserId)")
        
        /**
         * STEP 5: Create metadata for the file
         * - contentType: Tells Firebase this is a JPEG image
         * - cacheControl: How long browsers should cache the image (1 hour)
         */
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.cacheControl = "public,max-age=3600" // Cache for 1 hour
        
        do {
            /**
             * STEP 6: Upload image data to Storage
             * - putData(): Starts upload task
             * - await: Waits for upload to complete
             */
            let uploadTask = photoRef.putData(imageData, metadata: metadata)
            _ = try await uploadTask // Wait for upload to finish
            print("✅ File uploaded, getting download URL...")
            
            /**
             * STEP 7: Get download URL (public URL to access the image)
             * - downloadURL(): Gets permanent URL for the uploaded file
             * - This URL can be saved in Firestore and used to display the image
             */
            let downloadURL = try await photoRef.downloadURL()
            print("✅ Profile photo uploaded successfully: \(downloadURL.absoluteString)")
            return downloadURL.absoluteString // Return URL as String
        } catch {
            /**
             * ERROR HANDLING: Log detailed error information
             * - Helps debug upload failures
             * - Provides specific messages for common errors
             */
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
            
            // Re-throw with more context (wrapped in our custom error type)
            throw FirebaseProfileError.uploadFailed(underlyingError: error)
        }
    }
    
    /**
     * fetchProfilePhoto: Downloads profile photo from URL
     *
     * PARAMETER: urlString - Download URL from Firebase Storage
     * RETURNS: Optional UIImage - nil if download fails
     *
     * WHAT IT DOES:
     * 1. Converts URL string to URL object
     * 2. Downloads image data using URLSession
     * 3. Converts data to UIImage
     */
    func fetchProfilePhoto(urlString: String) async throws -> UIImage? {
        // Convert String to URL object
        guard let url = URL(string: urlString) else {
            return nil // Invalid URL
        }
        
        // Download image data from URL
        // URLSession.shared.data(from:): Downloads data from URL
        // Tuple destructuring: (data, _) - we only need data, ignore response
        let (data, _) = try await URLSession.shared.data(from: url)
        // Convert data to UIImage
        return UIImage(data: data)
    }
    
    /**
     * deleteProfilePhoto: Deletes profile photo from Firebase Storage
     *
     * PARAMETER: userId - Firebase Auth user ID
     *
     * WHAT IT DOES: Deletes file at users/{userId}/profile_photo.jpg
     */
    func deleteProfilePhoto(userId: String) async throws {
        // Create reference to the photo file
        let photoRef = storage.reference()
            .child("users")
            .child(userId)
            .child("profile_photo.jpg")
        
        // Delete the file
        try await photoRef.delete()
    }
}

/**
 * UserProfile: Data structure representing a user's profile
 *
 * WHAT IT IS: A struct - value type (copied when passed around)
 *
 * Codable: Protocol that allows automatic conversion to/from JSON
 * - Firestore uses this to save/load the struct
 * - No manual encoding/decoding needed!
 *
 * PROPERTIES:
 * - name: User's display name
 * - email: User's email address
 * - photoURL: Optional String - URL to profile photo in Firebase Storage
 */
struct UserProfile: Codable {
    var name: String
    var email: String
    var photoURL: String? // Optional - can be nil if no photo
}

/**
 * FirebaseProfileError: Custom error enum for profile operations
 *
 * WHAT IT IS: Enumeration with associated values
 *
 * LocalizedError: Protocol for user-friendly error messages
 *
 * CASES:
 * - imageConversionFailed: UIImage couldn't be converted to JPEG data
 * - uploadFailed: Upload to Firebase Storage failed (contains original error)
 */
enum FirebaseProfileError: LocalizedError {
    case imageConversionFailed
    case uploadFailed(underlyingError: Error) // Associated value - stores the original error
    
    /**
     * Computed property: User-friendly error message
     * switch: Pattern matching on enum case
     */
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to data."
        case .uploadFailed(let error): // Associated value - extracts the Error
            return "Upload failed: \(error.localizedDescription)"
        }
    }
    
    /**
     * Computed property: Access to underlying error (if any)
     * Useful for debugging - can inspect original error details
     */
    var underlyingError: Error? {
        switch self {
        case .uploadFailed(let error):
            return error // Return the associated error
        default:
            return nil // No underlying error for other cases
        }
    }
}

