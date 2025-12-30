//
//  ViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

final class AppTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appBackground

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = .tabSelectedGreen
        selected.titleTextAttributes = [.foregroundColor: UIColor.tabSelectedGreen]

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = .tabUnselectedDarkGreen
        normal.titleTextAttributes = [.foregroundColor: UIColor.tabUnselectedDarkGreen]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false
    }
}
