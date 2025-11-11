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
        
        let shelfVC = UINavigationController(rootViewController: BookshelfViewController())
        shelfVC.tabBarItem = UITabBarItem(title: "Shelf", image: UIImage(systemName: "books.vertical"), tag: 0)
        
        let exploreVC = UINavigationController(rootViewController: ExploreViewController())
        exploreVC.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "globe.desk"), tag: 1)
        
        viewControllers = [shelfVC, exploreVC]
    }
}
