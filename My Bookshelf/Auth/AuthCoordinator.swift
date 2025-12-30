//
//  AuthCoordinator.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.12.25.
//

import UIKit

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

    // MARK: - Login flow
    private func showLogin() {
        let loginVC = LoginViewController()
        loginVC.delegate = self

        navigationController.setViewControllers([loginVC], animated: false)
    }

    // MARK: - Main app
    private func showMainApp() {
        let tabBarController = UITabBarController()

        tabBarController.viewControllers = [
            makeNav(HomeViewController(), title: "Home", icon: "house"),
            makeNav(ExploreViewController(), title: "Explore", icon: "magnifyingglass"),
            makeNav(ListsViewController(), title: "Lists", icon: "list.bullet"),
            makeNav(ProfileViewController(), title: "Settings", icon: "gearshape")
        ]

        window.rootViewController = tabBarController
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
        showMainApp()
    }

    func didRequestLogout() {
        authManager.logout()
        start()   // Reset whole auth flow
    }
}
