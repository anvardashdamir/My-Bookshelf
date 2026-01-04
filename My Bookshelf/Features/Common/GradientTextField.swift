//
//  GradientTextField.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.11.25.
//

import UIKit

final class GradientTextField: UITextField {

    enum FieldStyle {
        case email
        case password
        case name
        case plain
    }

    private let containerLayer = CALayer()
    private let borderLayer = CAShapeLayer()
    private weak var passwordToggleButton: UIButton?

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
        let containerWidth: CGFloat = 44 + 16 // button tap area + trailing padding
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: fieldHeight))

        let button = UIButton(type: .system)
        button.tintColor = .secondaryLabel
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: fieldHeight)
        button.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)

        // place button with 16pt trailing padding inside container
        button.center = CGPoint(x: containerWidth - 16 - 22, y: fieldHeight / 2) // 22 = 44/2
        container.addSubview(button)

        passwordToggleButton = button
        rightView = container
        rightViewMode = .always
    }
    
    @objc private func togglePassword() {
        isSecureTextEntry.toggle()

        passwordToggleButton?.setImage(
            UIImage(systemName: isSecureTextEntry ? "eye.slash" : "eye"),
            for: .normal
        )

        // keep cursor position stable
        if let t = text { text = ""; insertText(t) }
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let defaultRect = super.clearButtonRect(forBounds: bounds)
        
        // 16pt trailing padding
        return defaultRect.offsetBy(dx: -22, dy: 0)
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
