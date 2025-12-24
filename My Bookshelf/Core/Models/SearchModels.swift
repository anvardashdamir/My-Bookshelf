//
//  SearchModels.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation

// Top-level search response: /search.json
struct SearchResponse: Decodable {
    let start: Int?
    let numFound: Int?
    let docs: [SearchDoc]
}

// One search result (a "work")
struct SearchDoc: Decodable {
    let key: String               // "/works/OL27448W"
    let title: String?
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverI: Int?
    let editionKey: [String]?
    let subject: [String]?
    let authorKey: [String]?
}

