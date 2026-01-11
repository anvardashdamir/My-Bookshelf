//
//  ListsViewModel.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation

final class ListsViewModel {
    
    // MARK: - State
    
    private(set) var lists: [BookList] = []
    
    // MARK: - Output
    
    var onStateChange: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Initialization
    
    init() {
        setupRepositoryObserver()
        loadLists()
    }
    
    // MARK: - Public Methods
    
    func loadLists() {
        lists = ListsRepository.shared.getAllLists()
        DispatchQueue.main.async { [weak self] in
            self?.onStateChange?()
        }
    }
    
    func createCustomList(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        ListsRepository.shared.createCustomList(name: trimmed)
        // State will be updated via repository observer
    }
    
    func deleteList(_ listId: UUID) {
        ListsRepository.shared.deleteList(listId)
        // State will be updated via repository observer
    }
    
    // MARK: - Private Methods
    
    private func setupRepositoryObserver() {
        ListsRepository.shared.onListsDidChange = { [weak self] in
            self?.loadLists()
        }
    }
}
