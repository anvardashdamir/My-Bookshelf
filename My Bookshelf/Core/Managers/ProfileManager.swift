//
//  ProfileManager.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.11.25.
//

import UIKit


final class ProfileManager {

    static let shared = ProfileManager()
    
    private let nameKey = "user_profile_name"
    private let emailKey = "user_profile_email"
    private let photoKey = "user_profile_photo"
    
  
    private init() {}
    
 
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

