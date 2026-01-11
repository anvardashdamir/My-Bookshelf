//
//  ListsViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

final class ListsViewController: UIViewController {
    
    private let viewModel = ListsViewModel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .appBackground
        cv.alwaysBounceVertical = true
        cv.register(ListCollectionCell.self, forCellWithReuseIdentifier: ListCollectionCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadLists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadLists()
    }

    private func setupUI() {
        title = "Lists"
        view.backgroundColor = .appBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addListTapped)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateItemSize()
    }

    private func updateItemSize() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let inset = layout.sectionInset
        let spacing = layout.minimumInteritemSpacing
        let availableWidth = view.bounds.width - inset.left - inset.right - spacing
        let itemWidth = floor(availableWidth / 2)    // 2 columns
        layout.itemSize = CGSize(width: itemWidth, height: 100)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        viewModel.onError = { [weak self] error in
            print("Error in ListsViewModel: \(error.localizedDescription)")
            // Could show alert here if needed
        }
    }

    @objc private func addListTapped() {
        let alert = UIAlertController(
            title: "New List",
            message: "Create a custom list for your books.",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "e.g. Fantasy, Classics, To Read"
            textField.autocapitalizationType = .words
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let name = alert.textFields?.first?.text {
                self.viewModel.createCustomList(name: name)
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(createAction)

        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ListsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.lists.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ListCollectionCell.reuseIdentifier,
            for: indexPath
        ) as? ListCollectionCell else {
            return UICollectionViewCell()
        }

        let list = viewModel.lists[indexPath.item]
        cell.configure(with: list)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ListsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = viewModel.lists[indexPath.item]
        let booksVC = ListBooksViewController(list: list)
        navigationController?.pushViewController(booksVC, animated: true)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let list = viewModel.lists[indexPath.item]
        
        guard list.type == .custom else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let delete = UIAction(
                title: "Delete \"\(list.name)\"",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.viewModel.deleteList(list.id)
            }
            return UIMenu(children: [delete])
        }
    }
}

