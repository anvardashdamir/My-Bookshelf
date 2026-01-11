//
//  ExploreSectionType.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation

enum ExploreSectionType: Int, CaseIterable {
    case discover = 0
    case recentlyViewed = 1

    var title: String {
        switch self {
        case .discover: return "Discover by Subject"
        case .recentlyViewed: return "Recently Viewed"
        }
    }
}
