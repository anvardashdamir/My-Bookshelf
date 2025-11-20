//
//  LibraryEndpoint.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Alamofire
import Foundation

struct OpenLibraryAPI {

    // Book Search API
    static func searchBooks(_ query: String, page: Int = 1) -> String {
        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return "https://openlibrary.org/search.json?q=\(q)&page=\(page)"
    }

    // Work Detail
    static func workDetail(_ workKey: String) -> String {
        // workKey is like "/works/OL82563W"
        return "https://openlibrary.org\(workKey).json"
    }

    // Edition Detail
    static func editionDetail(_ editionKey: String) -> String {
        return "https://openlibrary.org/books/\(editionKey).json"
    }

    // Authors API
    static func authorDetail(_ authorKey: String) -> String {
        return "https://openlibrary.org/authors/\(authorKey).json"
    }

    // Subjects API
    static func subjectBooks(_ subject: String, limit: Int = 20) -> String {
        let s = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        return "https://openlibrary.org/subjects/\(s).json?limit=\(limit)"
    }

    // Covers API (simple URL)
    static func coverURL(id: Int, size: String = "M") -> String {
        return "https://covers.openlibrary.org/b/id/\(id)-\(size).jpg"
    }
}
