//
//  ProfileCoordinator.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import UIKit
import Foundation

final class ProfileCoordinator {

    private let navigationController: UINavigationController
    weak var authFlowDelegate: AuthFlowDelegate?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ProfileViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - ProfileFlowDelegate
extension ProfileCoordinator: ProfileFlowDelegate {

    func didRequestLogout() {
        authFlowDelegate?.didRequestLogout()
    }

    func didRequestAccountDeletion() {
        authFlowDelegate?.didRequestLogout()
    }

    func didRequestEditProfile() {
//        let vc = EditProfileViewController()
//        navigationController.pushViewController(vc, animated: true)
    }
}
