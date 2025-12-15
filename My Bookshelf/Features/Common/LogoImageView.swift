//
//  LogoImageView.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 28.11.25.
//

import UIKit

final class LogoImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLogo()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLogo()
    }
    
    private func setupLogo() {
        image = UIImage(named: "logoImg")
        contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 140),
            heightAnchor.constraint(equalToConstant: 140)
        ])
    }
}

