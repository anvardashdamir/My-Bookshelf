//
//  ListBooksViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit
import FirebaseAuth

final class ListBooksViewController: UIViewController {

    private let list: BookList
    private let viewModel: ListBooksViewModel

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .appBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(FavoritesBookCell.self, forCellWithReuseIdentifier: FavoritesBookCell.reuseId)
        cv.dataSource = self
        cv.delegate = self

        return cv
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.text = "No books in this list yet."
        label.isHidden = true
        return label
    }()

    init(list: BookList) {
        self.list = list
        self.viewModel = ListBooksViewModel(listId: list.id)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = list.name
        setupUI()
        setupLongPressGesture()
        bindViewModel()
        viewModel.loadBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadBooks()
    }

    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] in
            guard let self = self else { return }
            self.emptyStateLabel.isHidden = !self.viewModel.books.isEmpty
            self.collectionView.reloadData()
        }
        
        viewModel.onError = { [weak self] error in
            print("Error in ListBooksViewModel: \(error.localizedDescription)")
            // Could show alert here if needed
        }
    }
    
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        
        guard indexPath.item < viewModel.books.count else { return }
        let book = viewModel.books[indexPath.item]
        showRemoveConfirmation(book: book, at: indexPath)
    }
    
    private func showRemoveConfirmation(book: BookResponse, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Remove Book",
            message: "Remove \"\(book.title)\" from this list?",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeBook(book, at: indexPath)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = collectionView
            popover.sourceRect = collectionView.cellForItem(at: indexPath)?.frame ?? .zero
        }
        
        present(alert, animated: true)
    }
    
    private func removeBook(_ book: BookResponse, at indexPath: IndexPath) {
        // Remove from ViewModel (which handles repository and Firebase)
        Task {
            await viewModel.removeBook(book)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ListBooksViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.books.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoritesBookCell.reuseId,
            for: indexPath
        ) as? FavoritesBookCell else {
            return UICollectionViewCell()
        }
        guard indexPath.item < viewModel.books.count else { return cell }
        cell.configure(with: viewModel.books[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ListBooksViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 12
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: width * 1.7)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < viewModel.books.count else { return }
        let book = viewModel.books[indexPath.item]
        let detailVC = BookDetailViewController(book: book)
        let nav = UINavigationController(rootViewController: detailVC)
        present(nav, animated: true)
    }
}

