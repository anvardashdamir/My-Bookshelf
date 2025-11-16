//
//  Coordinator.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var window: UIWindow? { get set }
    func start()
}
