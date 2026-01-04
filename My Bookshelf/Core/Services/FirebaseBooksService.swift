//
//  FirebaseBooksService.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import Foundation
import FirebaseFirestore

extension String {
    var firestoreDocId: String {
        replacingOccurrences(of: "/", with: "_")
    }
}

final class FirebaseBooksService {
    
    static let shared = FirebaseBooksService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    func saveBook(uid: String, book: BookDTO) async throws {
        let sanitizedDocId = book.bookId.firestoreDocId
        let bookRef = db.collection("users")
            .document(uid)
            .collection("books")
            .document(sanitizedDocId)
        
        try await bookRef.setData(from: book)
        print("✅ Book saved: \(book.bookId) (doc: \(sanitizedDocId)) for user: \(uid)")
    }
    
    func removeBook(uid: String, bookId: String) async throws {
        let sanitizedDocId = bookId.firestoreDocId
        let bookRef = db.collection("users")
            .document(uid)
            .collection("books")
            .document(sanitizedDocId)
        
        try await bookRef.delete()
        print("✅ Book removed: \(bookId) (doc: \(sanitizedDocId)) for user: \(uid)")
    }
    
    func fetchBooks(uid: String) async throws -> [BookDTO] {
        let booksRef = db.collection("users")
            .document(uid)
            .collection("books")
        
        let snapshot = try await booksRef.getDocuments()
        let books = try snapshot.documents.map { doc in
            try doc.data(as: BookDTO.self)
        }
        
        print("✅ Fetched \(books.count) books for user: \(uid)")
        return books
    }
}

struct BookDTO: Codable {
    let bookId: String
    let title: String
    let author: String
    let coverURL: String?
    let savedAt: Date
    let status: String?
    
    init(from book: BookResponse, status: String? = nil) {
        self.bookId = book.id
        self.title = book.title
        self.author = book.authors.first ?? "Unknown author"
        self.coverURL = book.coverURL?.absoluteString
        self.savedAt = Date()
        self.status = status
    }
    
    func toBookResponse() -> BookResponse {
        // Use memberwise initializer (struct provides this automatically)
        return BookResponse(
            id: bookId,
            title: title,
            authors: [author],
            firstPublishYear: nil,
            coverId: extractCoverId(from: coverURL)
        )
    }
    
    private func extractCoverId(from urlString: String?) -> Int? {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return nil
        }
        
        // Extract cover ID from URL like: https://covers.openlibrary.org/b/id/123456-L.jpg
        let path = url.lastPathComponent // "123456-L.jpg"
        let coverIdString = path.components(separatedBy: "-").first ?? ""
        return Int(coverIdString)
    }
}

