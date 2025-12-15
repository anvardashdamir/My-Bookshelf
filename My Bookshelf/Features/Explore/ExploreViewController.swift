//
//  ExploreViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

final class ExploreViewController: UIViewController {

    private let viewModel = ExploreViewModel()

    private let searchBarView = SearchBarView()

    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .appBackground
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        cv.register(BestOfMonthCell.self, forCellWithReuseIdentifier: BestOfMonthCell.reuseIdentifier)
        cv.register(BookHorizontalCell.self, forCellWithReuseIdentifier: BookHorizontalCell.reuseIdentifier)
        cv.register(ExploreSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ExploreSectionHeaderView.reuseIdentifier)
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadInitialData()
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

            collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 12),
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

    // MARK: - Layout

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let sectionType = ExploreSectionType(rawValue: sectionIndex) else {
                return nil
            }

            switch sectionType {
            case .bestOfMonth:
                return self.createBestOfMonthSection()
            case .brandNew, .fantasy:
                return self.createHorizontalBooksSection()
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

        let header = createHeader()
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

        let header = createHeader()
        section.boundarySupplementaryItems = [header]

        return section
    }

    private func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(30)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16)
        return header
    }
}

// MARK: - DataSource

extension ExploreViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ExploreSectionType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = ExploreSectionType(rawValue: section) else { return 0 }

        let books = viewModel.books(in: sectionType)
        switch sectionType {
        case .bestOfMonth:
            return 1 // show only first book as hero
        default:
            return books.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let sectionType = ExploreSectionType(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }

        let books = viewModel.books(in: sectionType)

        switch sectionType {
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
        let books = viewModel.books(in: sectionType)

        let book: Book
        if sectionType == .bestOfMonth {
            guard let first = books.first else { return }
            book = first
        } else {
            guard indexPath.item < books.count else { return }
            book = books[indexPath.item]
        }

        let detailVC = BookDetailViewController(book: book)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - SearchBarViewDelegate
extension ExploreViewController: SearchBarViewDelegate {
    func searchBarView(_ searchBarView: SearchBarView, didSubmit query: String) {
        let vc = SearchResultsViewController(query: query)
        navigationController?.pushViewController(vc, animated: true)
    }
}
