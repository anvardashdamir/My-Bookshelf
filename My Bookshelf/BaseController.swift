//
//  BaseController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 21.12.25.
//

import UIKit

open class BaseController: UIViewController {
    
    // MARK: - Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        hideKeyboardOnTap()
        configureUI()
        configureConstraints()
        configureViewModel()
    }
    
    open func configureUI() {}
    open func configureConstraints() {}
    open func configureViewModel() {}
}


// MARK: - Keyboard
extension BaseController {
    public func hideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - TextField
extension BaseController: UITextFieldDelegate {
    func setupFieldNavigation(_ fields: [UITextField]) {
        for (index, field) in fields.enumerated() {
            field.tag = index
            field.delegate = self
            field.returnKeyType = index == fields.count - 1 ? .done : .next
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let next = view.viewWithTag(textField.tag + 1) as? UITextField {
            next.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
