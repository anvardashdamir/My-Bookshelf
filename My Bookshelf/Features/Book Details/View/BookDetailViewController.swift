//
//  BookDetailViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import UIKit
import Alamofire
import FirebaseAuth

final class BookDetailViewController: UIViewController {

    private let book: BookResponse
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
    init(book: BookResponse) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Book"

        setupUI()
        configureWithBaseBook()
        fetchWorkDetail()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addBookToFavorites)
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Add book to recently viewed when detail view appears
        RecentlyViewedStore.shared.add(book)
    }
    
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Setup
    @objc private func addBookToFavorites() {
        showListPicker()
    }
    
    private func showListPicker() {
        let listPickerVC = ListPickerViewController(book: book)
        listPickerVC.onListSelected = { [weak self] list in
            guard let self = self,
                  let userId = AuthManager.shared.currentUserId else { return }
            
            Task {
                do {
                    try await ListsRepository.shared.addBookToFirebase(
                        book: self.book,
                        listType: list.type,
                        uid: userId
                    )
                    await MainActor.run {
                        self.showAddedToListAnimation(listName: list.name)
                    }
                } catch {
                    await MainActor.run {
                        self.showAlert(message: "Failed to save book: \(error.localizedDescription)")
                    }
                }
            }
        }
        let nav = UINavigationController(rootViewController: listPickerVC)
        present(nav, animated: true)
    }
    
    private func showAddedToListAnimation(listName: String) {
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

        let checkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkImageView.tintColor = .systemGreen
        checkImageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Added to \(listName)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(checkImageView)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            container.heightAnchor.constraint(equalToConstant: 70),

            checkImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            checkImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 28),
            checkImageView.heightAnchor.constraint(equalToConstant: 28),

            label.leadingAnchor.constraint(equalTo: checkImageView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

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
            UIView.animate(withDuration: 0.15,
                           animations: {
                checkImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    checkImageView.transform = .identity
                }
            })

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

        coverImageView.heightAnchor.constraint(equalToConstant: 550).isActive = true

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

    }
}
