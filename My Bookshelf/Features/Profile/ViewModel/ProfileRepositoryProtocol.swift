//
//  ProfileRepositoryProtocol.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import Foundation

protocol ProfileRepositoryProtocol {
    var userName: String { get }
    var userEmail: String { get }
    var profileImageData: Data? { get }
    func updateProfile(name: String?, email: String?, photoData: Data?)
}
