//
//  SearchResultsViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import UIKit
import Alamofire

final class SearchResultsViewController: UIViewController {

    private let query: String
    private var books: [Book] = []

    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Init

    init(query: String) {
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Results"

        setupTableView()
        performSearch()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(BasicBookCell.self, forCellReuseIdentifier: BasicBookCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }

    // MARK: - Networking

    private func performSearch() {
        let url = OpenLibraryAPI.searchBooks(query, page: 1)

        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SearchResponse, AFError>) in
            switch result {
            case .success(let response):
                let mapped = response.docs.map(Book.init(from:))
                self?.books = mapped
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Search error:", error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        books.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BasicBookCell.reuseIdentifier,
            for: indexPath
        ) as? BasicBookCell else {
            return UITableViewCell()
        }
        cell.configure(with: books[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchResultsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let book = books[indexPath.row]
        let detailVC = BookDetailViewController(book: book)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
