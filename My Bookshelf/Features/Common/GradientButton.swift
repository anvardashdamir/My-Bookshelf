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
        didSet {
            updateStyle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientBackground()
    }
    
    private func setupButton() {
        // Basic button setup
        layer.cornerRadius = 25
        layer.masksToBounds = true
        clipsToBounds = true
        
        titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        setupGradientBackground()
        updateStyle()
    }
    
    private func setupGradientBackground() {
        gradientLayer.cornerRadius = 25
        gradientLayer.masksToBounds = true
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateGradientBackground() {
        gradientLayer.frame = bounds
    }
    
    private func updateStyle() {
        switch buttonStyle {
        case .primary:
            // Green/Orange mix for login & register buttons
            gradientLayer.colors = [
                UIColor(red: 0.20, green: 0.80, blue: 0.40, alpha: 1.0).cgColor, // Green
                UIColor(red: 0.90, green: 0.49, blue: 0.13, alpha: 1.0).cgColor  // Orange
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            setTitleColor(.white, for: .normal)
            backgroundColor = .clear
                        
        case .destructive:
            // Orange/Red mix for logout button
            gradientLayer.colors = [
                UIColor(red: 0.90, green: 0.49, blue: 0.13, alpha: 1.0).cgColor, // Orange
                UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 1.0).cgColor  // Deep red
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            setTitleColor(.white, for: .normal)
            backgroundColor = .clear
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
    
    // MARK: - Convenience Initializers
    static func primary(title: String, height: CGFloat = 48) -> GradientButton {
        let button = GradientButton(type: .system)
        button.setTitle(title, for: .normal)
        button.buttonStyle = .primary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }
        
    static func destructive(title: String, height: CGFloat = 48) -> GradientButton {
        let button = GradientButton(type: .system)
        button.setTitle(title, for: .normal)
        button.buttonStyle = .destructive
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        return button
    }
}
