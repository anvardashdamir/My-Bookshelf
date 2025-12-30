//
//  AppTabBarBuilder.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 27.12.25.
//

import UIKit

enum AppTabBarBuilder {

    static func build() -> UITabBarController {
        let tabBar = AppTabBarViewController()

        tabBar.viewControllers = [
            makeTab(HomeViewController(), title: "Home", icon: "house", filled: true),
            makeTab(ExploreViewController(), title: "Explore", icon: "magnifyingglass"),
            makeTab(ListsViewController(), title: "Lists", icon: "list.bullet"),
            makeTab(ProfileViewController(), title: "Profile", icon: "person", filled: true)
        ]

        tabBar.selectedIndex = 0
        return tabBar
    }

    private static func makeTab(_ root: UIViewController, title: String, icon: String, filled: Bool = false) -> UINavigationController {

        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: filled ? "\(icon).fill" : icon)
        )
        return nav
    }
}
