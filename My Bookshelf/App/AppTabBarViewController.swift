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
        view.backgroundColor = .appBackground
        tabBar.backgroundColor = .appBackground
        tabBar.barTintColor = .appBackground
        tabBar.isTranslucent = false
    }
}
