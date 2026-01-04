//
//  HomeViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

enum HomeSection: Int, CaseIterable {
    case bestOfMonth = 0
    case brandNew = 1
    case fantasy = 2
}

final class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private let viewModel = ExploreViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .appBackground
        
        setupCollectionView()
        bindViewModel()
        viewModel.loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            
            guard let section = HomeSection(rawValue: sectionIndex) else {
                return self.createBestOfMonthSection()
            }
            
            switch section {
            case .bestOfMonth:
                return self.createBestOfMonthSection()
            case .brandNew, .fantasy:
                return self.createHorizontalBooksSection()
            }
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .appBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cells
        collectionView.register(
            BestOfMonthCell.self,
            forCellWithReuseIdentifier: BestOfMonthCell.reuseIdentifier
        )
        collectionView.register(
            BookHorizontalCell.self,
            forCellWithReuseIdentifier: BookHorizontalCell.reuseIdentifier
        )
        
        // Register header
        collectionView.register(
            HomeSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeSectionHeaderView.reuseIdentifier
        )
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func createBestOfMonthSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.92),
            heightDimension: .absolute(180)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 24, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createHorizontalBooksSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(130),
            heightDimension: .absolute(210)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 24, trailing: 16)
        section.interGroupSpacing = 12
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        HomeSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let homeSection = HomeSection(rawValue: section) else { return 0 }
        
        let books = viewModel.books(in: homeSection)
        switch homeSection {
        case .bestOfMonth:
            return 1
        default:
            return books.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = HomeSection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        let books = viewModel.books(in: section)
        
        switch section {
        case .bestOfMonth:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BestOfMonthCell.reuseIdentifier,
                for: indexPath
            ) as! BestOfMonthCell
            let firstBook = books.first
            cell.configure(with: firstBook)
            return cell
            
        case .brandNew, .fantasy:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BookHorizontalCell.reuseIdentifier,
                for: indexPath
            ) as! BookHorizontalCell
            guard indexPath.item < books.count else { return cell }
            cell.configure(with: books[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeSectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? HomeSectionHeaderView,
              let section = HomeSection(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }
        
        let title: String
        switch section {
        case .bestOfMonth:
            title = "Best of the Month"
        case .brandNew:
            title = "Brand New Titles"
        case .fantasy:
            title = "Popular in Fantasy"
        }
        
        header.configure(with: title)
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = HomeSection(rawValue: indexPath.section) else { return }
        
        let books = viewModel.books(in: section)
        
        let book: BookResponse
        if section == .bestOfMonth {
            guard let first = books.first else { return }
            book = first
        } else {
            guard indexPath.item < books.count else { return }
            book = books[indexPath.item]
        }
        
        let detailVC = BookDetailViewController(book: book)
        let nav = UINavigationController(rootViewController: detailVC)
        present(nav, animated: true)
    }
}

