//
//  AddFavAnimation.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 27.11.25.
//

import UIKit
import Foundation

extension UIViewController {
    func showAddedToFavoritesAnimation() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.alpha = 0
        view.addSubview(overlay)

        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowRadius = 10
        container.layer.shadowOffset = .zero
        container.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(container)

        let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartImageView.tintColor = .systemRed
        heartImageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Added to Favorites"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(heartImageView)
        container.addSubview(label)

        // Layout
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            container.heightAnchor.constraint(equalToConstant: 70),

            heartImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            heartImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            heartImageView.widthAnchor.constraint(equalToConstant: 28),
            heartImageView.heightAnchor.constraint(equalToConstant: 28),

            label.leadingAnchor.constraint(equalTo: heartImageView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        // Start small
        container.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut,
                       animations: {
            overlay.alpha = 1
            container.transform = .identity
        }, completion: { _ in
            // Little pulse on heart
            UIView.animate(withDuration: 0.15,
                           animations: {
                heartImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    heartImageView.transform = .identity
                }
            })

            // Fade out and remove
            UIView.animate(withDuration: 0.3,
                           delay: 0.9,
                           options: .curveEaseIn,
                           animations: {
                overlay.alpha = 0
                container.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: { _ in
                overlay.removeFromSuperview()
            })
        })
    }
}
