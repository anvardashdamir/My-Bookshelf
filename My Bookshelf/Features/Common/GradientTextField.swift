//
//  GradientTextField.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.11.25.
//

import UIKit
/*
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
*/

final class GradientTextField: UITextField {

    enum FieldStyle {
        case email
        case password
        case name
        case plain
    }

    private let containerLayer = CALayer()
    private let borderLayer = CAShapeLayer()

    private let paddingX: CGFloat = 14
    private let fieldHeight: CGFloat = 52
    private let corner: CGFloat = 14

    private var style: FieldStyle = .plain

    // Accent (Primary green)
    private var accentColorResolved: UIColor {
        let isDark = traitCollection.userInterfaceStyle == .dark
        return isDark ? UIColor(hex: "6FB1A3") : UIColor(hex: "2F5D50")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: corner).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyBaseColors()
            updateBorder(isFocused: isFirstResponder)
        }
    }

    // MARK: - Setup
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        borderStyle = .none

        heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        layer.cornerRadius = corner
        clipsToBounds = false

        font = .systemFont(ofSize: 15, weight: .medium)
        textColor = .label
        tintColor = accentColorResolved

        // background + subtle shadow (very light)
        containerLayer.cornerRadius = corner
        layer.insertSublayer(containerLayer, at: 0)

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 1
        layer.addSublayer(borderLayer)

        // Padding (left)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: paddingX, height: fieldHeight))
        leftViewMode = .always

        clearButtonMode = .whileEditing
        autocorrectionType = .no
        spellCheckingType = .no

        applyBaseColors()
        updateBorder(isFocused: false)

        addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    private func applyBaseColors() {
        let isDark = traitCollection.userInterfaceStyle == .dark

        // Soft surface, not harsh
        containerLayer.backgroundColor = (isDark ? UIColor.secondarySystemBackground : UIColor.systemGray6).cgColor

        // Placeholder color
        if let p = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: p,
                attributes: [.foregroundColor: UIColor.secondaryLabel]
            )
        }
    }

    private func updateBorder(isFocused: Bool) {
        if isFocused {
            borderLayer.strokeColor = accentColorResolved.cgColor
            borderLayer.lineWidth = 2
            // subtle focus glow
            layer.shadowColor = accentColorResolved.withAlphaComponent(0.35).cgColor
            layer.shadowOpacity = 1
            layer.shadowRadius = 10
            layer.shadowOffset = .zero
        } else {
            borderLayer.strokeColor = UIColor.separator.cgColor
            borderLayer.lineWidth = 1
            layer.shadowOpacity = 0
        }
    }

    @objc private func editingDidBegin() { updateBorder(isFocused: true) }
    @objc private func editingDidEnd() { updateBorder(isFocused: false) }

    // MARK: - Left icon helper (optional)
    private func setLeftIcon(systemName: String) {
        let imageView = UIImageView(image: UIImage(systemName: systemName))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit

        let w: CGFloat = 38
        let container = UIView(frame: CGRect(x: 0, y: 0, width: w, height: fieldHeight))
        imageView.frame = CGRect(x: 12, y: (fieldHeight - 18)/2, width: 18, height: 18)
        container.addSubview(imageView)

        leftView = container
        leftViewMode = .always
    }

    // MARK: - Password eye (optional)
    private func addPasswordToggle() {
        let button = UIButton(type: .system)
        button.tintColor = .secondaryLabel
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: fieldHeight)
        button.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)

        rightView = button
        rightViewMode = .always
    }

    @objc private func togglePassword() {
        isSecureTextEntry.toggle()
        if let b = rightView as? UIButton {
            b.setImage(UIImage(systemName: isSecureTextEntry ? "eye" : "eye.slash"), for: .normal)
        }
        // keep cursor position stable
        if let t = text { text = ""; insertText(t) }
    }

    // MARK: - Factory
    private static func make(_ style: FieldStyle, placeholder: String) -> GradientTextField {
        let tf = GradientTextField()
        tf.style = style
        tf.placeholder = placeholder
        tf.applyBaseColors()

        switch style {
        case .email:
            tf.keyboardType = .emailAddress
            tf.textContentType = .emailAddress
            tf.autocapitalizationType = .none
            tf.returnKeyType = .next
            tf.setLeftIcon(systemName: "envelope")

        case .password:
            tf.isSecureTextEntry = true
            tf.textContentType = .password
            tf.autocapitalizationType = .none
            tf.returnKeyType = .done
            tf.setLeftIcon(systemName: "lock")
            tf.addPasswordToggle()

        case .name:
            tf.textContentType = .name
            tf.autocapitalizationType = .words
            tf.returnKeyType = .next
            tf.setLeftIcon(systemName: "person")

        case .plain:
            break
        }

        return tf
    }

    static func email(placeholder: String = "Email") -> GradientTextField {
        make(.email, placeholder: placeholder)
    }

    static func password(placeholder: String = "Password") -> GradientTextField {
        make(.password, placeholder: placeholder)
    }

    static func name(placeholder: String = "Full name") -> GradientTextField {
        make(.name, placeholder: placeholder)
    }
}

// MARK: - Hex helper
private extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
