//
//  GradientTextField.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.11.25.
//

import UIKit

final class GradientTextField: UITextField {
    
    private let gradientLayer = CAGradientLayer()
    private let borderLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientBorder()
    }
    
    private func setupTextField() {
        // Basic text field setup
        borderStyle = .none
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 25 // Half of height (50/2) for fully rounded corners
        layer.masksToBounds = false
        clipsToBounds = false
        
        // Add padding
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        leftViewMode = .always
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        rightViewMode = .always
        
        // Setup gradient border
        setupGradientBorder()
    }
    
    private func setupGradientBorder() {
        // Gradient colors - fall/autumn colors
        gradientLayer.colors = [
            UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0).cgColor, // Golden
            UIColor(red: 0.90, green: 0.49, blue: 0.13, alpha: 1.0).cgColor, // Orange
            UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 1.0).cgColor, // Deep red
            UIColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1.0).cgColor  // Brown
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 25
        
        // Border layer
        borderLayer.lineWidth = 2.0
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.black.cgColor
        
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.mask = borderLayer
    }
    
    private func updateGradientBorder() {
        let path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 25
        )
        
        borderLayer.path = path.cgPath
        gradientLayer.frame = bounds
    }
    
    // MARK: - Convenience Initializers
    static func email(placeholder: String = "Email") -> GradientTextField {
        let textField = GradientTextField()
        textField.placeholder = placeholder
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textContentType = .emailAddress
        textField.returnKeyType = .next
        return textField
    }
    
    static func password(placeholder: String = "Password") -> GradientTextField {
        let textField = GradientTextField()
        textField.placeholder = placeholder
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textContentType = .password
        textField.returnKeyType = .done
        return textField
    }
    
    static func name(placeholder: String = "Full name") -> GradientTextField {
        let textField = GradientTextField()
        textField.placeholder = placeholder
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        return textField
    }
}

