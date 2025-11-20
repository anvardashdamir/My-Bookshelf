//
//  BasicBookCell.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import UIKit

final class BasicBookCell: UITableViewCell {

    static let reuseIdentifier = "BasicBookCell"

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, yearLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4

        let hStack = UIStackView(arrangedSubviews: [coverImageView, labelsStack])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center

        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            coverImageView.widthAnchor.constraint(equalToConstant: 52),
            coverImageView.heightAnchor.constraint(equalToConstant: 78)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        yearLabel.text = nil
    }

    func configure(with book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.authors.first ?? "Unknown author"
        if let year = book.firstPublishYear {
            yearLabel.text = "First published: \(year)"
        } else {
            yearLabel.text = nil
        }

        if let coverId = book.coverId,
           let url = URL(string: OpenLibraryAPI.coverURL(id: coverId, size: "S")) {
            loadImage(from: url)
        } else {
            coverImageView.image = UIImage(systemName: "book")
            coverImageView.contentMode = .scaleAspectFit
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.coverImageView.image = image
                self.coverImageView.contentMode = .scaleAspectFill
            }
        }.resume()
    }
}
