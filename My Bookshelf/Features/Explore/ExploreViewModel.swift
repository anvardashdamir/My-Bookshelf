//
//  ExploreViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation
import Alamofire

enum ExploreSectionType: Int, CaseIterable {
    case bestOfMonth
    case brandNew
    case fantasy

    var title: String {
        switch self {
        case .bestOfMonth: return "Best of the Month"
        case .brandNew:    return "Brand New Titles"
        case .fantasy:     return "Popular in Fantasy"
        }
    }
}

final class ExploreViewModel {

    // MARK: - Public Properties

    var bestOfMonth: [Book] = []
    var brandNew: [Book] = []
    var fantasy: [Book] = []

    // Callback to notify VC when data changes
    var onDataUpdated: (() -> Void)?

    // MARK: - Public Methods

    func loadInitialData() {
        fetchBestOfMonth()
        fetchBrandNew()
        fetchFantasy()
    }

    func books(in section: ExploreSectionType) -> [Book] {
        switch section {
        case .bestOfMonth: return bestOfMonth
        case .brandNew:    return brandNew
        case .fantasy:     return fantasy
        }
    }

    // MARK: - Networking
    private func fetchBestOfMonth() {
        // Example: treat "bestseller" search as "best of month" (for demo)
        let url = OpenLibraryAPI.searchBooks("bestseller")

        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SearchResponse, AFError>) in
            switch result {
            case .success(let response):
                self?.bestOfMonth = response.docs.map(Book.init(from:)).prefix(5).map { $0 }
                self?.onDataUpdated?()
            case .failure(let error):
                print("Best of month error:", error.localizedDescription)
            }
        }
    }

    private func fetchBrandNew() {
        // Example: search for "2023" to approximate newer titles
        let url = OpenLibraryAPI.searchBooks("2023")

        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SearchResponse, AFError>) in
            switch result {
            case .success(let response):
                self?.brandNew = response.docs.map(Book.init(from:)).prefix(15).map { $0 }
                self?.onDataUpdated?()
            case .failure(let error):
                print("Brand new error:", error.localizedDescription)
            }
        }
    }

    private func fetchFantasy() {
        // Use Subjects API for fantasy
        let url = OpenLibraryAPI.subjectBooks("fantasy", limit: 20)

        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SubjectResponse, AFError>) in
            switch result {
            case .success(let response):
                self?.fantasy = response.works.map(Book.init(from:)).prefix(15).map { $0 }
                self?.onDataUpdated?()
            case .failure(let error):
                print("Fantasy error:", error.localizedDescription)
            }
        }
    }
}
