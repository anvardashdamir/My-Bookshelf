//
//  ViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

class MainViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
    
    private func setupAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .secondaryLabel
        tabBar.isTranslucent = false
    }
    
}
