//
//  AuthManagerProtocol.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import Foundation

protocol AuthManagerProtocol {
    var currentUserId: String? { get }
    func logout() throws
    func deleteAccount(passwordForReauth: String?) async throws
}
