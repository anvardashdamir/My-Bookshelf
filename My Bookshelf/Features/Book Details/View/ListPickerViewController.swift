//
//  ListPickerViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

final class ListPickerViewController: UIViewController {
    
    private let book: BookResponse
    var onListSelected: ((BookList) -> Void)?
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .appBackground
        return tv
    }()
    
    private var lists: [BookList] = []
    
    init(book: BookResponse) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLists()
    }
    
    private func setupUI() {
        title = "Add to List"
        view.backgroundColor = .appBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadLists() {
        lists = ListsRepository.shared.getAllLists()
        tableView.reloadData()
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ListPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ListCell")
        let list = lists[indexPath.row]
        
        cell.textLabel?.text = list.name
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Check if book is already in this list
        if list.books.contains(book) {
            cell.textLabel?.textColor = .secondaryLabel
            cell.detailTextLabel?.text = "Already added"
            cell.detailTextLabel?.textColor = .secondaryLabel
        } else {
            cell.textLabel?.textColor = .label
            cell.detailTextLabel?.text = "\(list.bookCount) book\(list.bookCount == 1 ? "" : "s")"
            cell.detailTextLabel?.textColor = .secondaryLabel
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let list = lists[indexPath.row]
        
        // Don't add if already in list
        guard !list.books.contains(book) else {
            let alert = UIAlertController(
                title: "Already Added",
                message: "This book is already in \"\(list.name)\"",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        onListSelected?(list)
        dismiss(animated: true)
    }
}

