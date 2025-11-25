//
//  ListsViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit
import Foundation

struct ListBook {
    let id: UUID
    let title: String
    let author: String
    let coverURL: URL?
}

struct BookListItem {
    let id: UUID
    var title: String
    var books: [ListBook]
}

final class ListsViewController: UIViewController {

    // MARK: - UI

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return tv
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No lists yet.\nCreate your first reading list!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    // MARK: - Data

    private var lists: [BookListItem] = [] {
        didSet {
            tableView.reloadData()
            emptyStateLabel.isHidden = !lists.isEmpty
        }
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "My Lists"
        navigationController?.navigationBar.prefersLargeTitles = true

        setupTableView()
        setupLayout()
        setupNavigationItems()
        seedSampleData() // remove this when you hook real data
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListTableViewCell.self,
                           forCellReuseIdentifier: ListTableViewCell.reuseIdentifier)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addListTapped)
        )
    }

    // MARK: - Sample Data

    private func seedSampleData() {
        let book1 = ListBook(id: UUID(),
                         title: "The Pragmatic Programmer",
                         author: "Andrew Hunt, David Thomas",
                         coverURL: nil)
        let book2 = ListBook(id: UUID(),
                         title: "Clean Code",
                         author: "Robert C. Martin",
                         coverURL: nil)
        let book3 = ListBook(id: UUID(),
                         title: "Atomic Habits",
                         author: "James Clear",
                         coverURL: nil)

        let list1 = BookListItem(id: UUID(),
                             title: "Currently Reading",
                             books: [book1])
        let list2 = BookListItem(id: UUID(),
                             title: "Want to Read",
                             books: [book2, book3])
        let list3 = BookListItem(id: UUID(),
                             title: "Favorites",
                             books: [])

        lists = [list1, list2, list3]
    }

    // MARK: - Actions

    @objc private func addListTapped() {
        let alert = UIAlertController(title: "New List",
                                      message: "Enter a name for your list",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "List name"
            textField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
            guard let self = self,
                  let name = alert.textFields?.first?.text,
                  !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

            let newList = BookListItem(id: UUID(), title: name, books: [])
            self.lists.insert(newList, at: 0)
        }))
        present(alert, animated: true)
    }

    // MARK: - Public API

    func add(_ book: ListBook, toListAt index: Int) {
        guard lists.indices.contains(index) else { return }
        lists[index].books.append(book)
    }

    func configure(with lists: [BookListItem]) {
        self.lists = lists
    }
}

// MARK: - UITableViewDataSource

extension ListsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ListTableViewCell else {
            return UITableViewCell()
        }
        let list = lists[indexPath.row]
        cell.configure(with: list)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = lists[indexPath.row]
        // TODO: push a BookListDetailViewController showing books in this list
        print("Selected list: \(list.title)")
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.lists.remove(at: indexPath.row)
            completion(true)
        }

        let rename = UIContextualAction(style: .normal, title: "Rename") { [weak self] _, _, completion in
            guard let self = self else { return }
            let list = self.lists[indexPath.row]

            let alert = UIAlertController(title: "Rename List",
                                          message: "Update the name of your list",
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = list.title
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
                guard let newName = alert.textFields?.first?.text,
                      !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                self.lists[indexPath.row].title = newName
            }))
            self.present(alert, animated: true)

            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [delete, rename])
    }
}
