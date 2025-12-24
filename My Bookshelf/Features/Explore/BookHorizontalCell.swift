//
//  BookHorizontalCell.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import UIKit

final class BookHorizontalCell: UICollectionViewCell {

    static let reuseIdentifier = "BookHorizontalCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .darkGreen // explore screen book cells

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 2

        authorLabel.font = .systemFont(ofSize: 12)
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let stack = UIStackView(arrangedSubviews: [imageView, textStack])
        stack.axis = .vertical
        stack.spacing = 8

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.5)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
    }

    func configure(with book: BookResponse) {
        titleLabel.text = book.title
        authorLabel.text = book.authors.first ?? "Unknown author"

        if let coverId = book.coverId,
           let url = URL(string: OpenLibraryAPI.coverURL(id: coverId, size: "M")) {
            loadImage(from: url)
        } else {
            imageView.image = UIImage(systemName: "book")
            imageView.contentMode = .scaleAspectFit
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFill
            }
        }.resume()
    }
}
