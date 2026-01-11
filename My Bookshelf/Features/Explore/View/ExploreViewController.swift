//
//  ExploreViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

final class ExploreViewController: UIViewController {

    private let searchBarView = SearchBarView()
    
    private let subjects = ["fantasy", "science_fiction", "romance", "psychology", "business", "historical_fiction", "horror", "personal_growth", "food", "music", "politics", "poetry"]
    private var recentlyViewedBooks: [BookResponse] = []

    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .appBackground
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        cv.register(SubjectCell.self, forCellWithReuseIdentifier: SubjectCell.reuseIdentifier)
        cv.register(RecentlyViewedCell.self, forCellWithReuseIdentifier: RecentlyViewedCell.reuseIdentifier)
        cv.register(ExploreSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ExploreSectionHeaderView.reuseIdentifier)
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func setupUI() {
        title = "Explore"
        view.backgroundColor = .appBackground

        searchBarView.delegate = self

        view.addSubview(searchBarView)
        view.addSubview(collectionView)

        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBarView.heightAnchor.constraint(equalToConstant: 48),

            collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

    // MARK: - Layout

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let sectionType = ExploreSectionType(rawValue: sectionIndex) else {
                return nil
            }

            switch sectionType {
            case .discover:
                return self.createDiscoverSection()
            case .recentlyViewed:
                return self.createHorizontalScrollSection()
            }
        }
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
}

// MARK: - DataSource

extension ExploreViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ExploreSectionType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = ExploreSectionType(rawValue: section) else { return 0 }

        switch sectionType {
        case .discover:
            return subjects.count
        case .recentlyViewed:
            return recentlyViewedBooks.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let sectionType = ExploreSectionType(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }

        switch sectionType {
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
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = ExploreSectionType(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ExploreSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as! ExploreSectionHeaderView
        header.configure(title: sectionType.title)
        return header
    }
}

// MARK: - Delegate

extension ExploreViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = ExploreSectionType(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .discover:
            let subjectName = subjects[indexPath.item]
            let subjectVC = SubjectBooksViewController(subjectName: subjectName)
            navigationController?.pushViewController(subjectVC, animated: true)
            
        case .recentlyViewed:
            let book = recentlyViewedBooks[indexPath.item]
            let detailVC = BookDetailViewController(book: book)
            let nav = UINavigationController(rootViewController: detailVC)
            present(nav, animated: true)
        }
    }
}

// MARK: - SearchBarViewDelegate
extension ExploreViewController: SearchBarViewDelegate {
    func searchBarView(_ searchBarView: SearchBarView, didSubmit query: String) {
        let vc = SearchResultsViewController(query: query)
        navigationController?.pushViewController(vc, animated: true)
    }
}
