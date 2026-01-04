//
//  AuthCoordinator.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.12.25.
//

import UIKit
import FirebaseAuth

final class AuthCoordinator {

    private let window: UIWindow
    private let authManager: AuthManager
    private let navigationController = UINavigationController()

    init(
        window: UIWindow,
        authManager: AuthManager = .shared
    ) {
        self.window = window
        self.authManager = authManager
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        authManager.isLoggedIn ? showMainApp() : showLogin()
    }
    
    func startLoginFlow() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        showLogin()
    }

    // MARK: - Login flow
    private func showLogin() {
        let loginVC = LoginViewController(delegate: self)
        navigationController.setViewControllers([loginVC], animated: false)
    }

    private func showRegister() {
        let registerVC = RegisterViewController(delegate: self)
        navigationController.pushViewController(registerVC, animated: true)
    }
    
    
    // MARK: - Main app
    private func showMainApp() {
        let tabBarController = UITabBarController()
        
        let profileVC = ProfileViewController()
        profileVC.authDelegate = self

        tabBarController.viewControllers = [
            makeNav(HomeViewController(), title: "Home", icon: "house"),
            makeNav(ExploreViewController(), title: "Explore", icon: "magnifyingglass"),
            makeNav(ListsViewController(), title: "Lists", icon: "list.bullet"),
            makeNav(profileVC, title: "Profile", icon: "person")
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func makeNav(
        _ root: UIViewController,
        title: String,
        icon: String
    ) -> UINavigationController {

        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: "\(icon).fill")
        )
        return nav
    }
}

// MARK: - AuthFlowDelegate
extension AuthCoordinator: AuthFlowDelegate {

    func didAuthenticate() {
        print("✅ didAuthenticate called in AuthCoordinator")
        print("   Current user: \(Auth.auth().currentUser?.email ?? "nil")")
        print("   User ID: \(Auth.auth().currentUser?.uid ?? "nil")")
        showMainApp()
    }

    func didRequestLogout() {
        do {
            try authManager.logout()
            print("✅ Logout successful, resetting auth flow")
        } catch {
            print("⚠️ Logout error: \(error.localizedDescription)")
        }
        
        // Always reset auth flow after logout (even if logout failed)
        // This ensures we create a fresh LoginViewController with delegate
        startLoginFlow()
    }
}
