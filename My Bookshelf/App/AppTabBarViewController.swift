//
//  ViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

class AppTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.backgroundColor = .appBackground
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = .appBackground                                   // tab bar background
        appearance.stackedLayoutAppearance.selected.iconColor = .tabSelectedGreen     // selected tab item icon color
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [           // selected tab item title color
            .foregroundColor: UIColor.tabSelectedGreen
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = .tabUnselectedDarkGreen // unselected tab item icon color
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [             // unselected tab item title color
            .foregroundColor: UIColor.tabUnselectedDarkGreen
        ]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false                                                  // disable translucency for solid background
        
        // Fallback background color
//        tabBar.backgroundColor = .appBackground
    }
}
