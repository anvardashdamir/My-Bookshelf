//
//  ExploreViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation
import Alamofire

final class ExploreViewModel {

    // MARK: - Public Properties

    var bestOfMonth: [BookResponse] = []
    var brandNew: [BookResponse] = []
    var fantasy: [BookResponse] = []

    // Callback to notify VC when data changes
    var onDataUpdated: (() -> Void)?

    // MARK: - Public Methods

    func loadInitialData() {
        fetchBestOfMonth()
        fetchBrandNew()
        fetchFantasy()
    }

    func books(in section: HomeSection) -> [BookResponse] {
        switch section {
        case .bestOfMonth: return bestOfMonth
        case .brandNew:    return brandNew
        case .fantasy:     return fantasy
        }
    }

    // MARK: - Networking
    private func fetchBestOfMonth() {
        let url = OpenLibraryAPI.searchBooks("bestseller")

        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SearchResponse, AFError>) in
            switch result {
            case .success(let response):
                self?.bestOfMonth = response.docs.map(BookResponse.init(from:)).prefix(5).map { $0 }
                self?.onDataUpdated?()
            case .failure(let error):
                print("Best of month error:", error.localizedDescription)
            }
        }
    }

    private func fetchBrandNew() {
        let url = OpenLibraryAPI.searchBooks("2023")

        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SearchResponse, AFError>) in
            switch result {
            case .success(let response):
                self?.brandNew = response.docs.map(BookResponse.init(from:)).prefix(15).map { $0 }
                self?.onDataUpdated?()
            case .failure(let error):
                print("Brand new error:", error.localizedDescription)
            }
        }
    }

    private func fetchFantasy() {
        let url = OpenLibraryAPI.subjectBooks("fantasy", limit: 20)

        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SubjectResponse, AFError>) in
            switch result {
            case .success(let response):
                self?.fantasy = response.works.map(BookResponse.init(from:)).prefix(15).map { $0 }
                self?.onDataUpdated?()
            case .failure(let error):
                print("Fantasy error:", error.localizedDescription)
            }
        }
    }
}
