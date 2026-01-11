//
//  SubjectBooksViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation
import Alamofire

final class SubjectBooksViewModel {
    
    // MARK: - State
    
    private(set) var books: [BookResponse] = []
    private(set) var isLoading: Bool = false
    
    // MARK: - Output
    
    var onStateChange: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Properties
    
    let subjectName: String
    
    // MARK: - Initialization
    
    init(subjectName: String) {
        self.subjectName = subjectName
    }
    
    // MARK: - Public Methods
    
    func loadBooks() {
        isLoading = true
        DispatchQueue.main.async { [weak self] in
            self?.onStateChange?()
        }
        
        let url = OpenLibraryAPI.subjectBooks(subjectName, limit: 50)
        
        NetworkManager.shared.fetch(url: url) { [weak self] (result: Result<SubjectResponse, AFError>) in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.books = response.works.map(BookResponse.init(from:))
                DispatchQueue.main.async {
                    self.onStateChange?()
                }
            case .failure(let error):
                print("Subject books error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.onError?(error)
                }
            }
        }
    }
}
