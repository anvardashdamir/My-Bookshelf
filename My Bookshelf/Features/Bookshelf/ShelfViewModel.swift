//
//  ShelfViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation
import UIKit

struct ShelfCollection: Identifiable, Equatable {
    let id: UUID
    var name: String
    var bookCount: Int
    let createdAt: Date

    init(id: UUID = UUID(), name: String, bookCount: Int = 0, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.bookCount = bookCount
        self.createdAt = createdAt
    }
}

final class ShelfViewModel {

    private(set) var collections: [ShelfCollection] = []

    // In a real app this would talk to a repository / Core Data
    init() {
        // TEMP: starter example shelves so UI doesn’t look empty
        collections = [
            ShelfCollection(name: "Currently Reading", bookCount: 2),
            ShelfCollection(name: "Want to Read", bookCount: 5),
            ShelfCollection(name: "Finished", bookCount: 12)
        ]
    }

    // MARK: - CRUD

    func numberOfCollections() -> Int {
        collections.count
    }

    func collection(at indexPath: IndexPath) -> ShelfCollection {
        collections[indexPath.item]
    }

    func addCollection(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let new = ShelfCollection(name: trimmed)
        collections.insert(new, at: 0)
    }

    func deleteCollection(at indexPath: IndexPath) {
        guard collections.indices.contains(indexPath.item) else { return }
        collections.remove(at: indexPath.item)
    }
}
