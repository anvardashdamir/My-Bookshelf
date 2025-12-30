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
        guard let style = UserDefaults.standard.string(forKey: "userInterfaceStyle") else { return }
        overrideUserInterfaceStyle = style == "dark" ? .dark : .light
    }
}
