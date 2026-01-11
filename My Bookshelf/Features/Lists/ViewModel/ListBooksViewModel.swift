//
//  ListBooksViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation
import FirebaseAuth

final class ListBooksViewModel {
    
    // MARK: - State
    
    private let listId: UUID
    private(set) var books: [BookResponse] = []
    
    // MARK: - Output
    
    var onStateChange: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Initialization
    
    init(listId: UUID) {
        self.listId = listId
        setupRepositoryObserver()
        loadBooks()
    }
    
    // MARK: - Public Methods
    
    func loadBooks() {
        if let updatedList = ListsRepository.shared.getList(byId: listId) {
            books = updatedList.books
            DispatchQueue.main.async { [weak self] in
                self?.onStateChange?()
            }
        }
    }
    
    func removeBook(_ book: BookResponse) async {
        // Remove from repository
        ListsRepository.shared.removeBook(book, fromListId: listId)
        
        // Remove from Firebase if user is authenticated
        if let uid = Auth.auth().currentUser?.uid {
            do {
                try await FirebaseBooksService.shared.removeBook(uid: uid, bookId: book.id)
                print("Book removed from Firebase: \(book.id)")
            } catch {
                print("Failed to remove book from Firebase: \(error.localizedDescription)")
                await MainActor.run {
                    self.onError?(error)
                }
            }
        }
        
        // Reload books to reflect changes
        loadBooks()
    }
    
    // MARK: - Private Methods
    
    private func setupRepositoryObserver() {
        ListsRepository.shared.onListsDidChange = { [weak self] in
            self?.loadBooks()
        }
    }
}
