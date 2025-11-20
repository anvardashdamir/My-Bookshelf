//
//  BookDetailViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import UIKit
import Alamofire

final class BookDetailViewController: UIViewController {

    private let book: Book
    private var workDetail: WorkDetail?

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIStackView()

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let subjectsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Subjects"
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()

    private let subjectsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Init

    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Book"

        setupUI()
        configureWithBaseBook()
        fetchWorkDetail()
    }

    // MARK: - Setup

    private func setupUI() {
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.alignment = .fill
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Layout
        let headerStack = UIStackView(arrangedSubviews: [coverImageView, titleLabel, authorLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 12

        contentView.addArrangedSubview(headerStack)

        coverImageView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        contentView.addArrangedSubview(descriptionTitleLabel)
        contentView.addArrangedSubview(descriptionLabel)

        contentView.addArrangedSubview(subjectsTitleLabel)
        contentView.addArrangedSubview(subjectsLabel)
    }

    private func configureWithBaseBook() {
        titleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        descriptionLabel.text = "Loading description..."
        subjectsLabel.text = "Loading subjects..."

        if let coverId = book.coverId,
           let url = URL(string: OpenLibraryAPI.coverURL(id: coverId, size: "L")) {
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

    // MARK: - Networking

    private func fetchWorkDetail() {
        let url = OpenLibraryAPI.workDetail(book.id)  // book.id is work key like "/works/OLxxxxW"

        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<WorkDetail, AFError>) in
            switch result {
            case .success(let detail):
                self?.workDetail = detail
                DispatchQueue.main.async {
                    self?.updateUI(with: detail)
                }
            case .failure(let error):
                print("Work detail error:", error.localizedDescription)
                DispatchQueue.main.async {
                    // Fallback if nothing loaded
                    if self?.descriptionLabel.text == "Loading description..." {
                        self?.descriptionLabel.text = "No description available."
                    }
                    if self?.subjectsLabel.text == "Loading subjects..." {
                        self?.subjectsLabel.text = "No subjects available."
                    }
                }
            }
        }
    }

    private func updateUI(with detail: WorkDetail) {
        if let desc = detail.description?.value, !desc.isEmpty {
            descriptionLabel.text = desc
        } else {
            descriptionLabel.text = "No description available."
        }

        if let subjects = detail.subjects, !subjects.isEmpty {
            subjectsLabel.text = subjects.joined(separator: ", ")
        } else {
            subjectsLabel.text = "No subjects available."
        }

        // If cover not present in base book, you could also use detail.covers?.first here
    }
}
