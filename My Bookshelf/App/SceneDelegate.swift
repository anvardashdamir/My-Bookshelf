//
//  SceneDelegate.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Apply saved dark mode preference
        if let savedStyle = UserDefaults.standard.string(forKey: "userInterfaceStyle") {
            window.overrideUserInterfaceStyle = savedStyle == "dark" ? .dark : .light
        }

        // Check authentication status
        if AuthManager.shared.isLoggedIn {
            // User is logged in, show main app
            startMainApp()
        } else {
            // User is not logged in, show login screen
            startLoginFlow()
        }
    }
    
    func startMainApp() {
        let tabBarController = AppTabBarViewController()

        let homeNav = UINavigationController(rootViewController: HomeViewController())
        let exploreNav = UINavigationController(rootViewController: ExploreViewController())
        let listsNav = UINavigationController(rootViewController: ListsViewController())
        let settingsNav = UINavigationController(rootViewController: ProfileViewController())

        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        exploreNav.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        listsNav.tabBarItem = UITabBarItem(
            title: "Lists",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )

        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        tabBarController.viewControllers = [
            homeNav,
            exploreNav,
            listsNav,
            settingsNav
        ]

        tabBarController.selectedIndex = 0

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    func startLoginFlow() {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        let nav = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}

// MARK: - LoginViewControllerDelegate
extension SceneDelegate: LoginViewControllerDelegate {
    func didCompleteLogin() {
        startMainApp()
    }
}

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

