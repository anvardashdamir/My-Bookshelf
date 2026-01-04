//
//  RecentlyViewedStore.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation

final class RecentlyViewedStore {
    static let shared = RecentlyViewedStore()
    
    private(set) var books: [BookResponse] = []
    private let maxCount = 20
    
    var onBooksDidChange: (() -> Void)?
    
    private init() {}
    
    func add(_ book: BookResponse) {
        // Remove if already exists to avoid duplicates
        books.removeAll { $0.id == book.id }
        
        // Add to beginning
        books.insert(book, at: 0)
        
        // Limit to maxCount
        if books.count > maxCount {
            books = Array(books.prefix(maxCount))
        }
        
        onBooksDidChange?()
    }
    
    func clear() {
        books.removeAll()
        onBooksDidChange?()
    }
    
    func clearAll() {
        clear()
        print("✅ RecentlyViewedStore: All recently viewed books cleared")
    }
}

