//
//  SearchResultsViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation
import Alamofire

final class SearchResultsViewModel {
    
    // MARK: - State
    
    private(set) var books: [BookResponse] = []
    private(set) var isLoading: Bool = false
    
    // MARK: - Output
    
    var onStateChange: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Properties
    
    let query: String
    
    // MARK: - Initialization
    
    init(query: String) {
        self.query = query
    }
    
    // MARK: - Public Methods
    
    func performSearch() {
        isLoading = true
        DispatchQueue.main.async { [weak self] in
            self?.onStateChange?()
        }
        
        let url = OpenLibraryAPI.searchBooks(query, page: 1)
        
        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SearchResponse, AFError>) in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.books = response.docs.map(BookResponse.init(from:))
                DispatchQueue.main.async {
                    self.onStateChange?()
                }
            case .failure(let error):
                print("Search error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.onError?(error)
                }
            }
        }
    }
}
