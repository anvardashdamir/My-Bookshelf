//
//  ListsManager.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation

final class ListsManager {
    static let shared = ListsManager()
    
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
}

