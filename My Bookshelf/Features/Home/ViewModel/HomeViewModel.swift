//
//  HomeViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation
import Alamofire

final class HomeViewModel {
    
    // MARK: - State
    
    private(set) var bestOfMonth: [BookResponse] = []
    private(set) var brandNew: [BookResponse] = []
    private(set) var fantasy: [BookResponse] = []
    
    // MARK: - Output/State Change
    
    var onStateChange: (() -> Void)?
    var onError: ((Error) -> Void)?
    
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
                DispatchQueue.main.async {
                    self?.onStateChange?()
                }
            case .failure(let error):
                print("Best of month error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self?.onError?(error)
                }
            }
        }
    }
    
    private func fetchBrandNew() {
        let url = OpenLibraryAPI.searchBooks("2023")
        
        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SearchResponse, AFError>) in
            switch result {
            case .success(let response):
                self?.brandNew = response.docs.map(BookResponse.init(from:)).prefix(15).map { $0 }
                DispatchQueue.main.async {
                    self?.onStateChange?()
                }
            case .failure(let error):
                print("Brand new error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self?.onError?(error)
                }
            }
        }
    }
    
    private func fetchFantasy() {
        let url = OpenLibraryAPI.subjectBooks("fantasy", limit: 20)
        
        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SubjectResponse, AFError>) in
            switch result {
            case .success(let response):
                self?.fantasy = response.works.map(BookResponse.init(from:)).prefix(15).map { $0 }
                DispatchQueue.main.async {
                    self?.onStateChange?()
                }
            case .failure(let error):
                print("Fantasy error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self?.onError?(error)
                }
            }
        }
    }
}
