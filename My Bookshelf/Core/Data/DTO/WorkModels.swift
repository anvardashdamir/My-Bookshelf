//
//  WorkModels.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation

// Wrapper to handle description being either String or { "value": "..." }
struct OLText: Decodable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self.value = string
        } else {
            // Try object { value: String }
            let obj = try container.decode(OLTextObject.self)
            self.value = obj.value
        }
    }

    private struct OLTextObject: Decodable {
        let value: String
    }
}

// /works/{id}.json
struct WorkDetail: Decodable {
    let key: String                // "/works/OL27448W"
    let title: String
    let description: OLText?
    let subjects: [String]?
    let covers: [Int]?
    let firstPublishDate: String?
}

