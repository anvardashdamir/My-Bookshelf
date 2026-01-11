//
//  UserDefaultsProtocol.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import Foundation

protocol UserDefaultsProtocol {
    func data(forKey defaultName: String) -> Data?
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol {}
