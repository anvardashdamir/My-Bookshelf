//
//  BaseController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 21.12.25.
//

import UIKit

class BaseController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraints()
        configureViewModel()
    }
    
    func configureUI() {}
    func configureConstraints() {}
    func configureViewModel() {}
}
