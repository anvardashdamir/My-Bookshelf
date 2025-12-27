//
//  HomeViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

enum HomeSection: Int, CaseIterable {
    case recentlyViewed = 0
    case statistics = 1
    case discover = 2
}

final class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    private let subjects = ["fantasy", "science_fiction", "romance", "psychology", "business"]
    private var recentlyViewedBooks: [BookResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .appBackground
        
        setupCollectionView()
        setupObservers()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            
            guard let section = HomeSection(rawValue: sectionIndex) else {
                return self.createDiscoverSection()
            }
            
            switch section {
            case .recentlyViewed:
                return self.createHorizontalScrollSection()
            case .statistics:
                return self.createStatisticsSection()
            case .discover:
                return self.createDiscoverSection()
            }
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .appBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cells
        collectionView.register(
            RecentlyViewedCell.self,
            forCellWithReuseIdentifier: RecentlyViewedCell.reuseIdentifier
        )
        collectionView.register(
            StatsCardCell.self,
            forCellWithReuseIdentifier: StatsCardCell.reuseIdentifier
        )
        collectionView.register(
            SubjectCell.self,
            forCellWithReuseIdentifier: SubjectCell.reuseIdentifier
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
    
    private func createHorizontalScrollSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(100),
            heightDimension: .absolute(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(100),
            heightDimension: .absolute(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createStatisticsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createDiscoverSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(56)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(56)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(12)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func setupObservers() {
        RecentlyViewedStore.shared.onBooksDidChange = { [weak self] in
            self?.loadData()
        }
    }
    
    private func loadData() {
        recentlyViewedBooks = RecentlyViewedStore.shared.books
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        HomeSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let homeSection = HomeSection(rawValue: section) else { return 0 }
        
        switch homeSection {
        case .recentlyViewed:
            return recentlyViewedBooks.count
        case .statistics:
            return 1
        case .discover:
            return subjects.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = HomeSection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .recentlyViewed:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecentlyViewedCell.reuseIdentifier,
                for: indexPath
            ) as? RecentlyViewedCell else {
                return UICollectionViewCell()
            }
            let book = recentlyViewedBooks[indexPath.item]
            cell.configure(with: book)
            return cell
            
        case .statistics:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: StatsCardCell.reuseIdentifier,
                for: indexPath
            ) as? StatsCardCell else {
                return UICollectionViewCell()
            }
            return cell
            
        case .discover:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SubjectCell.reuseIdentifier,
                for: indexPath
            ) as? SubjectCell else {
                return UICollectionViewCell()
            }
            let subject = subjects[indexPath.item]
            cell.configure(with: subject)
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
        case .recentlyViewed:
            title = "Recently Viewed"
        case .statistics:
            title = "2025 Statistics"
        case .discover:
            title = "Discover by Subject"
        }
        
        header.configure(with: title)
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = HomeSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .recentlyViewed:
            // Tapping a book in Recently Viewed opens BookDetailViewController
            let book = recentlyViewedBooks[indexPath.item]
            let detailVC = BookDetailViewController(book: book)
            let nav = UINavigationController(rootViewController: detailVC)
            present(nav, animated: true)
            
        case .statistics:
            let statsVC = StatsViewController()
            navigationController?.pushViewController(statsVC, animated: true)
            
        case .discover:
            let subjectName = subjects[indexPath.item]
            let subjectVC = SubjectBooksViewController(subjectName: subjectName)
            navigationController?.pushViewController(subjectVC, animated: true)
        }
    }
}
