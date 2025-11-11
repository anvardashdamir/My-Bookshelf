//
//  BookshelfViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

class BookshelfViewController: UIViewController {

    private let header: UILabel = {
        let label = UILabel()
        label.text = "My Bookshelf"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addShelf: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
     }()
    
    private let shelfCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .blue
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        addShelf.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }

    private func setupUI() {
        view.addSubview(header)
        view.addSubview(addShelf)
        view.addSubview(shelfCollectionView)

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            addShelf.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            addShelf.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addShelf.widthAnchor.constraint(equalToConstant: 44),
            addShelf.heightAnchor.constraint(equalToConstant: 44),
            
            shelfCollectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            shelfCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            shelfCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            shelfCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func addTapped() {
        print("Add Shelf Tapped")
    }
}
