//
//  GradientButton.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.11.25.
//

import UIKit

final class GradientButton: UIButton {

    private let gradientLayer = CAGradientLayer()

    enum ButtonStyle {
        case primary
        case destructive
    }

    var buttonStyle: ButtonStyle = .primary {
        didSet { applyStyle() }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyStyle()
        }
    }

    // MARK: - Setup
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 14
        clipsToBounds = true

        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)

        setTitleColor(.white, for: .normal)

        configuration = nil
        applyStyle()
    }

    private func applyStyle() {
        let isDark = traitCollection.userInterfaceStyle == .dark

        switch buttonStyle {
        case .primary:
            if isDark {
                gradientLayer.colors = [
                    UIColor(hex: "6FB1A3").cgColor,
                    UIColor(hex: "89C6B9").cgColor
                ]
                setTitleColor(UIColor(hex: "0E1F1B"), for: .normal)
            } else {
                gradientLayer.colors = [
                    UIColor(hex: "2F5D50").cgColor,
                    UIColor(hex: "3F7668").cgColor
                ]
                setTitleColor(.white, for: .normal)
            }

        case .destructive:
            if isDark {
                gradientLayer.colors = [
                    UIColor(hex: "FF6B6B").cgColor,
                    UIColor(hex: "E85B5B").cgColor
                ]
                setTitleColor(UIColor(hex: "2A0B0B"), for: .normal)
            } else {
                gradientLayer.colors = [
                    UIColor(hex: "D64545").cgColor,
                    UIColor(hex: "B83A3A").cgColor
                ]
                setTitleColor(.white, for: .normal)
            }
        }
    }

    // MARK: - Highlight
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.alpha = self.isHighlighted ? 0.92 : 1.0
            }
        }
    }

    // MARK: - Convenience
    static func primary(title: String, height: CGFloat = 48) -> GradientButton {
        let b = GradientButton(type: .system)
        b.setTitle(title, for: .normal)
        b.buttonStyle = .primary
        b.heightAnchor.constraint(equalToConstant: height).isActive = true
        return b
    }

    static func destructive(title: String, height: CGFloat = 48) -> GradientButton {
        let b = GradientButton(type: .system)
        b.setTitle(title, for: .normal)
        b.buttonStyle = .destructive
        b.heightAnchor.constraint(equalToConstant: height).isActive = true
        return b
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
