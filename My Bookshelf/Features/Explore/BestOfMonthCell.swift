//
//  BestOfMonthCell.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import UIKit

final class BestOfMonthCell: UICollectionViewCell {

    static let reuseIdentifier = "BestOfMonthCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor(red: 195/255, green: 172/255, blue: 131/255, alpha: 1) // explore screen "best of the month" view color

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let stack = UIStackView(arrangedSubviews: [imageView, textStack])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.5)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(with book: BookResponse?) {
        guard let book = book else {
            titleLabel.text = "No book available"
            subtitleLabel.text = nil
            imageView.image = UIImage(systemName: "book")
            imageView.contentMode = .scaleAspectFit
            return
        }

        titleLabel.text = book.title
        subtitleLabel.text = book.authors.first ?? "Unknown author"

        if let coverId = book.coverId,
           let url = URL(string: OpenLibraryAPI.coverURL(id: coverId, size: "L")) {
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
