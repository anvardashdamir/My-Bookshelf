//
//  UIView+Layout.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.12.25.
//

import UIKit
import Foundation

extension UIView {
    func setHeight(_ value: CGFloat) {
        heightAnchor.constraint(equalToConstant: value).isActive = true
    }
}
