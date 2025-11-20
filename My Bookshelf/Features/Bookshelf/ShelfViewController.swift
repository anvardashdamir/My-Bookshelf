//
//  ShelfViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

final class ShelfViewController: UIViewController {

    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.alwaysBounceVertical = true
        cv.register(ShelfCollectionCell.self,
                    forCellWithReuseIdentifier: ShelfCollectionCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    // MARK: - Properties

    private let viewModel = ShelfViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateItemSize()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Bookshelf"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCollectionTapped)
        )

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateItemSize() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let inset = layout.sectionInset
        let spacing = layout.minimumInteritemSpacing
        let availableWidth = view.bounds.width - inset.left - inset.right - spacing
        let itemWidth = floor(availableWidth / 2)    // 2 columns
        layout.itemSize = CGSize(width: itemWidth, height: 100)
    }

    // MARK: - Actions

    @objc private func addCollectionTapped() {
        let alert = UIAlertController(
            title: "New Collection",
            message: "Give your collection a name.",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "e.g. Fantasy, To Read, Classics"
            textField.autocapitalizationType = .words
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let name = alert.textFields?.first?.text, !name.trimmingCharacters(in: .whitespaces).isEmpty {
                self.viewModel.addCollection(named: name)
                self.collectionView.reloadData()
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(createAction)

        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension ShelfViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfCollections()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ShelfCollectionCell.reuseIdentifier,
            for: indexPath
        ) as? ShelfCollectionCell else {
            return UICollectionViewCell()
        }

        let shelf = viewModel.collection(at: indexPath)
        cell.configure(with: shelf)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ShelfViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let shelf = viewModel.collection(at: indexPath)
        let booksVC = ShelfBooksViewController(shelf: shelf)
        navigationController?.pushViewController(booksVC, animated: true)
    }

    // Optional: swipe-to-delete support for collections (iOS 13+)

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let shelf = viewModel.collection(at: indexPath)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let delete = UIAction(
                title: "Delete \"\(shelf.name)\"",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.viewModel.deleteCollection(at: indexPath)
                self?.collectionView.deleteItems(at: [indexPath])
            }
            return UIMenu(children: [delete])
        }
    }
}
