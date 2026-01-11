//
//  UIViewController+Alert.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.12.25.
//

import UIKit

extension UIViewController {

    func showAlert(title: String? = nil, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
