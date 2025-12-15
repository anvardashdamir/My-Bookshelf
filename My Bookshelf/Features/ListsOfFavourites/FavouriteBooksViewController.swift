//
//  ListsViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit
import Foundation

// MARK: - FavouriteBooksViewController (Grid stil)
final class FavouriteBooksViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var favouriteBooks: [Book] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favourites"
        view.backgroundColor = .appBackground
        setupCollectionView()
        loadData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favouritesDidChange),
            name: FavouriteBooksManager.favouritesDidChangeNotification,
            object: nil
        )
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .appBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(FavouriteBookCell.self, forCellWithReuseIdentifier: FavouriteBookCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadData() {
        favouriteBooks = FavouriteBooksManager.shared.favouriteBooks
        collectionView.reloadData()
    }

    @objc private func favouritesDidChange() {
        loadData()
    }
}

extension FavouriteBooksViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favouriteBooks.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavouriteBookCell.reuseId,
            for: indexPath
        ) as? FavouriteBookCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: favouriteBooks[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 12
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: width * 1.7)
    }
}
