//
//  UIWindow+Extensions.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 27.12.25.
//

import UIKit

extension UIWindow {

    func setRoot(_ vc: UIViewController) {
        rootViewController = vc
        makeKeyAndVisible()
    }

    func applySavedInterfaceStyle() {
        if let style = UserDefaults.standard.string(forKey: "userInterfaceStyle") {
            overrideUserInterfaceStyle = style == "dark" ? .dark : .light
        } else {
            // Default to dark mode if no preference is saved
            overrideUserInterfaceStyle = .dark
        }
    }
}
