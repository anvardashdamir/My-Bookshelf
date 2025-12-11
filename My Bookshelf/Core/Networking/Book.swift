//
//  Book.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation

struct Book: Identifiable, Equatable, Hashable {
    let id: String          // use work key: "/works/OL27448W"
    let title: String
    let authors: [String]
    let firstPublishYear: Int?
    let coverId: Int?
}

// MARK: - Mappers
extension Book {
    init(from doc: SearchDoc) {
        self.id = doc.key
        self.title = doc.title ?? "Untitled"
        self.authors = doc.authorName ?? []
        self.firstPublishYear = doc.firstPublishYear
        self.coverId = doc.coverI
    }

    init(from work: SubjectWork) {
        self.id = work.key
        self.title = work.title ?? "Untitled"
        self.authors = (work.authors ?? []).compactMap { $0.name }
        self.firstPublishYear = work.firstPublishYear
        self.coverId = work.coverId
    }
}

extension Book {
    var coverURL: URL? {
        guard let coverId else { return nil }
        // OpenLibrary cover url (m = medium, L = large)
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverId)-L.jpg")
    }

    var authorsText: String {
        authors.joined(separator: ", ")
    }
}
