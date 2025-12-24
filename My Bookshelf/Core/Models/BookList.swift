//
//  BookList.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation

enum ListType: String, CaseIterable {
    case currentlyReading = "Currently Reading"
    case finished = "Finished"
    case wantToRead = "Want to Read"
    case custom = "Custom"
}

struct BookList: Identifiable, Equatable {
    let id: UUID
    var name: String
    var type: ListType
    var books: [BookResponse]
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        type: ListType,
        books: [BookResponse] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.books = books
        self.createdAt = createdAt
    }
    
    var bookCount: Int {
        books.count
    }
}

