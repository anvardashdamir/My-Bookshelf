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
            UserDefaults.standard.string(forKey: nameKey) ?? "John Smith"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: nameKey)
        }
    }
    
    var userEmail: String {
        get {
            UserDefaults.standard.string(forKey: emailKey) ?? AuthManager.shared.currentUserEmail ?? "john.smith@example.com"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: emailKey)
        }
    }
    
    var profilePhoto: UIImage? {
        get {
            guard let data = UserDefaults.standard.data(forKey: photoKey),
                  let image = UIImage(data: data) else {
                return UIImage(named: "profile_photo")
            }
            return image
        }
        set {
            if let image = newValue,
               let data = image.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(data, forKey: photoKey)
            } else {
                UserDefaults.standard.removeObject(forKey: photoKey)
            }
        }
    }
    
    func updateProfile(name: String?, email: String?, photo: UIImage?) {
        if let name = name, !name.isEmpty {
            userName = name
        }
        if let email = email, !email.isEmpty {
            userEmail = email
        }
        if let photo = photo {
            profilePhoto = photo
        }
    }
}

