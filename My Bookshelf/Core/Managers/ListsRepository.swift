//
//  ListsRepository.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation

final class ListsRepository {
    static let shared = ListsRepository()
    
    private(set) var lists: [BookList] = []
    
    var onListsDidChange: (() -> Void)?
    
    private init() {
        lists = [
            BookList(name: "Currently Reading", type: .currentlyReading),
            BookList(name: "Finished", type: .finished),
            BookList(name: "Want to Read", type: .wantToRead)
        ]
    }
    
    func getAllLists() -> [BookList] {
        lists
    }
    
    func getList(byId id: UUID) -> BookList? {
        lists.first { $0.id == id }
    }
    
    func getList(byType type: ListType) -> BookList? {
        lists.first { $0.type == type }
    }
    
    func replaceAll(with firebaseBooks: [BookDTO]) {
        // Clear all lists
        lists = [
            BookList(name: "Currently Reading", type: .currentlyReading),
            BookList(name: "Finished", type: .finished),
            BookList(name: "Want to Read", type: .wantToRead)
        ]
        
        // Map books by status to appropriate lists
        for bookDTO in firebaseBooks {
            let book = bookDTO.toBookResponse()
            let status = bookDTO.status ?? "Want to Read"
            
            // Map status to ListType
            let listType: ListType
            switch status {
            case "Currently Reading":
                listType = .currentlyReading
            case "Finished":
                listType = .finished
            case "Want to Read":
                listType = .wantToRead
            default:
                listType = .wantToRead
            }
            
            addBook(book, toListType: listType)
        }
        
        onListsDidChange?()
        print("✅ ListsRepository: Replaced with \(firebaseBooks.count) books from Firebase")
    }
    
    func addBook(_ book: BookResponse, toListType listType: ListType) {
        guard let list = getList(byType: listType),
              let index = lists.firstIndex(where: { $0.id == list.id }) else { return }
        
        if !lists[index].books.contains(book) {
            lists[index].books.append(book)
        }
    }
    
    func addBook(_ book: BookResponse, toListId listId: UUID) {
        guard let index = lists.firstIndex(where: { $0.id == listId }) else { return }
        
        if !lists[index].books.contains(book) {
            lists[index].books.append(book)
            onListsDidChange?()
        }
    }
    
    func removeBook(_ book: BookResponse, fromListId listId: UUID) {
        guard let index = lists.firstIndex(where: { $0.id == listId }) else { return }
        lists[index].books.removeAll { $0 == book }
        onListsDidChange?()
    }
    
    func addBookToFirebase(book: BookResponse, listType: ListType, uid: String) async throws {
        let bookDTO = BookDTO(from: book, status: listType.rawValue)
        try await FirebaseBooksService.shared.saveBook(uid: uid, book: bookDTO)
        
        await MainActor.run {
            addBook(book, toListType: listType)
            onListsDidChange?()
        }
    }
    
    func removeBookFromFirebase(book: BookResponse, uid: String) async throws {
        try await FirebaseBooksService.shared.removeBook(uid: uid, bookId: book.id)
        
        // Remove from all lists locally
        await MainActor.run {
            for index in lists.indices {
                lists[index].books.removeAll { $0 == book }
            }
            onListsDidChange?()
        }
    }
    
    func createCustomList(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newList = BookList(name: trimmed, type: .custom)
        lists.append(newList)
        onListsDidChange?()
    }
    
    func deleteList(_ listId: UUID) {
        lists.removeAll { $0.id == listId }
        onListsDidChange?()
    }
    
    func updateList(_ listId: UUID, name: String) {
        guard let index = lists.firstIndex(where: { $0.id == listId }) else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lists[index].name = trimmed
        onListsDidChange?()
    }
    
    func clearAllLists() {
        lists = [
            BookList(name: "Currently Reading", type: .currentlyReading),
            BookList(name: "Finished", type: .finished),
            BookList(name: "Want to Read", type: .wantToRead)
        ]
        onListsDidChange?()
        print("✅ ListsRepository: All lists cleared and reset to defaults")
    }
}

