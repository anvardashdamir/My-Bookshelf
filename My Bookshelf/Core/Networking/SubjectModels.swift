//
//  SubjectModels.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation

// /subjects/{subject}.json
struct SubjectResponse: Decodable {
    let key: String?               // e.g. "/subjects/fantasy"
    let name: String?
    let subjectType: String?
    let workCount: Int?
    let works: [SubjectWork]
}

struct SubjectWork: Decodable {
    let key: String                // "/works/OL82563W"
    let title: String?
    let editionCount: Int?
    let coverId: Int?
    let firstPublishYear: Int?
    let subject: [String]?
    let authors: [SubjectAuthor]?
}

struct SubjectAuthor: Decodable {
    let key: String?               // "/authors/OL26320A"
    let name: String?
}
