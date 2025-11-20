//
//  AuthorModels.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation

// /authors/{id}.json
struct AuthorDetail: Decodable {
    let key: String                // "/authors/OL26320A"
    let name: String
    let personalName: String?
    let birthDate: String?
    let deathDate: String?
    let bio: OLText?               // same OLText as above
    let photos: [Int]?             // for author image if you want
}
