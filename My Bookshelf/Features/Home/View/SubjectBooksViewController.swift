//
//  SubjectBooksViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

final class SubjectBooksViewController: UIViewController {
    
    private let viewModel: SubjectBooksViewModel
    
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
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(subjectName: String) {
        self.viewModel = SubjectBooksViewModel(subjectName: subjectName)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.subjectName.capitalized
        view.backgroundColor = .appBackground
        setupUI()
        bindViewModel()
        viewModel.loadBooks()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] in
            guard let self = self else { return }
            if self.viewModel.isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] error in
            guard let self = self else { return }
            self.loadingIndicator.stopAnimating()
            let alert = UIAlertController(
                title: "Error",
                message: "Failed to load books. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SubjectBooksViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
extension SubjectBooksViewController: UICollectionViewDelegateFlowLayout {
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

