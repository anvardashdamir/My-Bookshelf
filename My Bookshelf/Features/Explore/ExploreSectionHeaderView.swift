//
//  ExploreSectionHeaderView.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import UIKit

final class ExploreSectionHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "ExploreSectionHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
