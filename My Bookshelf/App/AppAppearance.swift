//
//  AppAppearance.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 03.01.26.
//

import UIKit

enum AppAppearance {

    static func apply() {
        configureTabBar()
        // gələcəkdə: configureNavBar(), configureSearchBar() və s.
    }

    private static func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appBackground
        appearance.backgroundEffect = nil

        // Selected
        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = .tabSelected
        selected.titleTextAttributes = [.foregroundColor: UIColor.tabSelected]

        // Unselected
        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = .tabUnselected
        normal.titleTextAttributes = [.foregroundColor: UIColor.tabUnselected]

        let proxy = UITabBar.appearance()
        proxy.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            proxy.scrollEdgeAppearance = appearance
        }

        // These make it consistent across iOS versions
        proxy.tintColor = .tabSelected
        proxy.unselectedItemTintColor = .tabUnselected
        proxy.isTranslucent = false
        
        proxy.backgroundColor = .appBackground
        proxy.barTintColor = .appBackground
    }
}
