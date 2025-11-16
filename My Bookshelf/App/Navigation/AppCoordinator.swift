//
//  AppCoordinator.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

final class AppCoordinator: Coordinator {

    var window: UIWindow?

    private var tabBarController: MainViewController?

    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        let tabBarController = MainViewController()

        // Create root view controllers for each tab
        let shelfNav = UINavigationController(rootViewController: ShelfViewController())
        let exploreNav = UINavigationController(rootViewController: ExploreViewController())
        let listsNav = UINavigationController(rootViewController: ListsViewController())
        let settingsNav = UINavigationController(rootViewController: SettingsViewController())

        shelfNav.tabBarItem = UITabBarItem(
            title: "Shelf",
            image: UIImage(systemName: "books.vertical"),
            selectedImage: UIImage(systemName: "books.vertical.fill")
        )

        exploreNav.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        listsNav.tabBarItem = UITabBarItem(
            title: "Lists",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )

        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        tabBarController.viewControllers = [
            shelfNav,
            exploreNav,
            listsNav,
            settingsNav
        ]

        tabBarController.selectedIndex = 1

        self.tabBarController = tabBarController

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}
