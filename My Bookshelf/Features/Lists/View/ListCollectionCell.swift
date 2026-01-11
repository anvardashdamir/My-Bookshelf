//
//  ListCollectionCell.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

final class ListCollectionCell: UICollectionViewCell {

    static let reuseIdentifier = "ListCollectionCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .darkGreen
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        let textStack = UIStackView(arrangedSubviews: [nameLabel, countLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let hStack = UIStackView(arrangedSubviews: [iconView, textStack])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center

        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        countLabel.text = nil
        iconView.image = nil
    }

    func configure(with list: BookList) {
        nameLabel.text = list.name
        
        let count = list.bookCount
        if count == 1 {
            countLabel.text = "1 book"
        } else {
            countLabel.text = "\(count) books"
        }
        
        // Set icon based on list type
        switch list.type {
        case .currentlyReading:
            iconView.image = UIImage(systemName: "book.fill")
        case .finished:
            iconView.image = UIImage(systemName: "checkmark.circle.fill")
        case .wantToRead:
            iconView.image = UIImage(systemName: "bookmark.fill")
        case .custom:
            iconView.image = UIImage(systemName: "books.vertical.fill")
        }
    }
}

