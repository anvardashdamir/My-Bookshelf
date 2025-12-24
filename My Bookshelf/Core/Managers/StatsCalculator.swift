//
//  StatsCalculator.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation

final class StatsCalculator {
    static let shared = StatsCalculator()
    
    private init() {}
    
    // MARK: - Properties
    
    /// Total number of books read (from "Finished" list)
    var totalReadBooks: Int {
        let finishedList = ListsManager.shared.getAllLists().first { $0.type == .finished }
        return finishedList?.books.count ?? 0
    }
    
    /// Count of each genre/subject across read books
    var genreCounts: [String: Int] {
        let finishedList = ListsManager.shared.getAllLists().first { $0.type == .finished }
        guard let books = finishedList?.books else { return [:] }
        
        var counts: [String: Int] = [:]
        
        // For now, we'll need to fetch work details to get subjects
        // This is a simplified version - in a real app, you'd cache work details
        // For now, return empty and we'll enhance this later
        return counts
    }
    
    /// Top genres sorted by count (descending)
    func topGenres(limit: Int = 5) -> [(genre: String, count: Int)] {
        let sorted = genreCounts.sorted { $0.value > $1.value }
        return Array(sorted.prefix(limit)).map { (genre: $0.key, count: $0.value) }
    }
    
    /// Monthly counts for books read (1-12 representing months)
    var monthlyCounts: [Int: Int] {
        // This would require tracking readDate for each book
        // For now, return empty dictionary
        // In a real implementation, you'd store readDate with each book in the list
        return [:]
    }
    
    // MARK: - Helper Methods
    
    /// Get all statistics as a dictionary
    func getAllStats() -> [String: Any] {
        return [
            "totalReadBooks": totalReadBooks,
            "genreCounts": genreCounts,
            "topGenres": topGenres(),
            "monthlyCounts": monthlyCounts
        ]
    }
}

