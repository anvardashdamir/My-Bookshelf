//
//  SearchBarView.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import UIKit

protocol SearchBarViewDelegate: AnyObject {
    func searchBarView(_ searchBarView: SearchBarView, didSubmit query: String)
}

final class SearchBarView: UIView {

    weak var delegate: SearchBarViewDelegate?

    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search books, authors, ISBN..."
        tf.returnKeyType = .search
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.autocapitalizationType = .none
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        return tf
    }()

    private let borderLayer = CAShapeLayer()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyColors(isFocused: textField.isFirstResponder)
        }
    }

    // MARK: - UI
    private func setupUI() {
        layer.cornerRadius = 16
        clipsToBounds = false

        // Border
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 1
        layer.addSublayer(borderLayer)

        let stack = UIStackView(arrangedSubviews: [iconView, textField])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
        ])

        textField.delegate = self
        textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)

        applyColors(isFocused: false)
    }

    private func accentColorResolved() -> UIColor {
        traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "6FB1A3") : UIColor(hex: "2F5D50")
    }

    private func applyColors(isFocused: Bool) {
        let isDark = traitCollection.userInterfaceStyle == .dark

        // Card-like surface
        backgroundColor = isDark ? UIColor(hex: "1A211F") : .white

        // Icon + cursor accent
        iconView.tintColor = .secondaryLabel
        textField.tintColor = accentColorResolved()
        textField.textColor = .label

        // Placeholder
        if let p = textField.placeholder {
            textField.attributedPlaceholder = NSAttributedString(
                string: p,
                attributes: [.foregroundColor: UIColor.secondaryLabel]
            )
        }

        // Border + focus glow
        borderLayer.strokeColor = (isFocused ? accentColorResolved() : UIColor.separator).cgColor
        borderLayer.lineWidth = isFocused ? 2 : 1

        if isFocused {
            layer.shadowColor = accentColorResolved().withAlphaComponent(0.30).cgColor
            layer.shadowOpacity = 1
            layer.shadowRadius = 10
            layer.shadowOffset = .zero
        } else {
            layer.shadowOpacity = 0
        }
    }

    @objc private func editingDidBegin() { applyColors(isFocused: true) }
    @objc private func editingDidEnd() { applyColors(isFocused: false) }
}

// MARK: - UITextFieldDelegate
extension SearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !text.isEmpty {
            delegate?.searchBarView(self, didSubmit: text)
        }
        textField.resignFirstResponder()
        return true
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
