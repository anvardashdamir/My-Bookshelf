//
//  ProfileManager.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.11.25.
//

import UIKit

/**
 * ProfileManager: Singleton that manages user profile data locally
 *
 * RESPONSIBILITIES:
 * - Stores user name, email, and profile photo in UserDefaults
 * - Provides easy access to profile data throughout the app
 * - Handles image compression when saving photos
 *
 * STORAGE: UserDefaults (local, persistent storage on device)
 * DESIGN PATTERN: Singleton - one shared instance
 *
 * NOTE: This is for LOCAL storage. Firebase data is managed by FirebaseProfileService
 */
final class ProfileManager {
    /**
     * Singleton instance - accessed via ProfileManager.shared
     */
    static let shared = ProfileManager()
    
    /**
     * STORAGE KEYS: Constants used as keys in UserDefaults
     * - nameKey: Stores user's name
     * - emailKey: Stores user's email
     * - photoKey: Stores user's profile photo (as JPEG data)
     */
    private let nameKey = "user_profile_name"
    private let emailKey = "user_profile_email"
    private let photoKey = "user_profile_photo"
    
    /**
     * Private init: Prevents creating new instances (enforces singleton)
     */
    private init() {}
    
    /**
     * COMPUTED PROPERTY: userName
     * 
     * GETTER: Reads from UserDefaults, returns default "John Smith" if nil
     * SETTER: Saves to UserDefaults
     * 
     * UserDefaults: iOS key-value storage (persists between app launches)
     * ?? "John Smith": Nil coalescing - use default value if nil
     */
    var userName: String {
        get {
            // Read from UserDefaults, or use default value
            UserDefaults.standard.string(forKey: nameKey) ?? "John Smith"
        }
        set {
            // Save to UserDefaults
            UserDefaults.standard.set(newValue, forKey: nameKey)
        }
    }
    
    /**
     * COMPUTED PROPERTY: userEmail
     * 
     * GETTER: Tries UserDefaults first, then AuthManager, then default
     * SETTER: Saves to UserDefaults
     * 
     * CHAINED NIL COALESCING: ?? ?? - tries multiple fallback values
     */
    var userEmail: String {
        get {
            // Try UserDefaults first, then AuthManager, then default
            UserDefaults.standard.string(forKey: emailKey) 
                ?? AuthManager.shared.currentUserEmail 
                ?? "john.smith@example.com"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: emailKey)
        }
    }
    
    /**
     * COMPUTED PROPERTY: profilePhoto
     * 
     * GETTER: 
     * 1. Reads JPEG data from UserDefaults
     * 2. Converts data to UIImage
     * 3. Returns default image if conversion fails
     * 
     * SETTER:
     * 1. Converts UIImage to JPEG data (compression quality 0.8 = 80%)
     * 2. Saves data to UserDefaults
     * 3. Removes key if image is nil
     * 
     * OPTIONAL BINDING: if let - safely unwraps optionals
     */
    var profilePhoto: UIImage? {
        get {
            // Try to load image data from UserDefaults
            guard let data = UserDefaults.standard.data(forKey: photoKey),
                  let image = UIImage(data: data) else {
                // If loading fails, return default image
                return UIImage(named: "profile_photo")
            }
            return image
        }
        set {
            // OPTIONAL BINDING: if let - only executes if newValue is not nil
            if let image = newValue,
               let data = image.jpegData(compressionQuality: 0.8) {
                // Convert UIImage to JPEG data (80% quality) and save
                UserDefaults.standard.set(data, forKey: photoKey)
            } else {
                // If image is nil or conversion fails, remove from storage
                UserDefaults.standard.removeObject(forKey: photoKey)
            }
        }
    }
    
    /**
     * updateProfile: Updates profile data (name, email, and/or photo)
     * 
     * PARAMETERS: All optional - only updates fields that are provided
     * - name: Optional String - user's name
     * - email: Optional String - user's email
     * - photo: Optional UIImage - user's profile photo
     * 
     * WHAT IT DOES:
     * - Only updates non-nil, non-empty values
     * - Uses computed property setters (which save to UserDefaults)
     */
    func updateProfile(name: String?, email: String?, photo: UIImage?) {
        // OPTIONAL BINDING + CONDITION: Only update if value exists and is not empty
        if let name = name, !name.isEmpty {
            userName = name // Calls setter, saves to UserDefaults
        }
        if let email = email, !email.isEmpty {
            userEmail = email
        }
        if let photo = photo {
            profilePhoto = photo // Calls setter, converts to JPEG and saves
        }
    }
}

