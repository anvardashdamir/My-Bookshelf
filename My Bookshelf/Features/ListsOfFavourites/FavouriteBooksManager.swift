//
//  FavouriteBooksManager.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.12.25.
//

import Foundation
import UIKit

final class FavouriteBooksManager {
    static let shared = FavouriteBooksManager()
    
    static let favouritesDidChangeNotification = Notification.Name("favouritesDidChangeNotification")
    
    private(set) var favouriteBooks: [Book] = []
    
    private init() { }
    
    func add(_ book: Book) {
           if !favouriteBooks.contains(book) {
               favouriteBooks.append(book)
               NotificationCenter.default.post(name: Self.favouritesDidChangeNotification, object: nil)
           }
    }
    
    func remove(_ book: Book) {
        if let index = favouriteBooks.firstIndex(of: book) {
            favouriteBooks.remove(at: index)
            NotificationCenter.default.post(name: Self.favouritesDidChangeNotification, object: nil)
        }
    }
}
