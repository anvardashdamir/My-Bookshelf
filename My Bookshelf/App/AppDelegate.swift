//
//  AppDelegate.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit
import FirebaseCore

/**
 * AppDelegate: The main entry point of the iOS application
 *
 * RESPONSIBILITIES:
 * - Manages app lifecycle events (launch, background, foreground, etc.)
 * - Initializes Firebase when the app starts
 * - Handles scene session configuration
 *
 * @main attribute: Marks this as the entry point - iOS calls this class first when app launches
 */
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /**
     * Called when the app finishes launching
     *
     * PARAMETERS:
     * - application: The singleton UIApplication instance representing the app
     * - launchOptions: Dictionary containing info about why the app was launched
     *                 (e.g., from a notification, URL, etc.)
     *
     * RETURNS: Bool - true if launch was successful
     *
     * WHAT IT DOES:
     * 1. Configures Firebase SDK (reads GoogleService-Info.plist)
     * 2. Sets up Firebase services (Auth, Firestore, Storage)
     * 3. Must be called before using any Firebase features
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase - reads GoogleService-Info.plist and initializes all Firebase services
        // This MUST be called before any Firebase operations (Auth, Firestore, Storage)
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

