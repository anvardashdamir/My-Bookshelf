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
    private var books: [BookResponse] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .appBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(FavouriteBookCell.self, forCellWithReuseIdentifier: FavouriteBookCell.reuseId)
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
        loadBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBooks()
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

    private func loadBooks() {
        if let updatedList = ListsManager.shared.getList(byId: list.id) {
            books = updatedList.books
            emptyStateLabel.isHidden = !books.isEmpty
            collectionView.reloadData()
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
        
        let book = books[indexPath.item]
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
        // 1. Remove from UI
        books.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        emptyStateLabel.isHidden = !books.isEmpty
        
        // 2. Remove from ListsManager
        ListsManager.shared.removeBook(book, fromListId: list.id)
        
        // 3. Remove from Firebase if uid exists
        if let uid = Auth.auth().currentUser?.uid {
            Task {
                do {
                    try await FirebaseBooksService.shared.removeBook(uid: uid, bookId: book.id)
                    print("✅ Book removed from Firebase: \(book.id)")
                } catch {
                    print("⚠️ Failed to remove book from Firebase: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ListBooksViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        books.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavouriteBookCell.reuseId,
            for: indexPath
        ) as? FavouriteBookCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: books[indexPath.item])
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
        let book = books[indexPath.item]
        let detailVC = BookDetailViewController(book: book)
        let nav = UINavigationController(rootViewController: detailVC)
        present(nav, animated: true)
    }
}

