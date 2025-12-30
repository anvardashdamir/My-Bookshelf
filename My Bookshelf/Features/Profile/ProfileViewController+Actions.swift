//
//  ProfileViewController+Actions.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 29.12.25.
//

import UIKit
import Foundation

// MARK: - Actions setup
extension ProfileViewController {

    func setupActions() {
        // Dark mode
        darkModeSwitch.addTarget(
            self,
            action: #selector(darkModeSwitchChanged(_:)),
            for: .valueChanged
        )

        // Account actions
        logoutButton.addTarget(
            self,
            action: #selector(logoutTapped),
            for: .touchUpInside
        )

        deleteAccountButton.addTarget(
            self,
            action: #selector(deleteAccountTapped),
            for: .touchUpInside
        )

        // Profile image tap
        let imageTap = UITapGestureRecognizer(
            target: self,
            action: #selector(profileImageTapped)
        )
        profileImageView.addGestureRecognizer(imageTap)

        // Edit profile
        editButton.addTarget(
            self,
            action: #selector(editProfileTapped),
            for: .touchUpInside
        )

        // Info buttons
        privacyButton.addTarget(
            self,
            action: #selector(privacyTapped),
            for: .touchUpInside
        )

        aboutUsButton.addTarget(
            self,
            action: #selector(aboutUsTapped),
            for: .touchUpInside
        )
    }
}

// MARK: - Button actions
extension ProfileViewController {

    @objc private func darkModeSwitchChanged(_ sender: UISwitch) {
        let style: UIUserInterfaceStyle = sender.isOn ? .dark : .light
        UserDefaults.standard.set(sender.isOn ? "dark" : "light", forKey: "userInterfaceStyle")

        guard let scene = view.window?.windowScene else { return }
        scene.windows.forEach { $0.overrideUserInterfaceStyle = style }
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.coordinator?.didRequestLogout()
        })

        present(alert, animated: true)
    }

    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            Task {
                do {
                    try await self?.viewModel.deleteAccount()
                    self?.coordinator?.didRequestAccountDeletion()
                } catch {
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        })

        present(alert, animated: true)
    }

    @objc private func profileImageTapped() {
        showImageSourceAlert()
    }

    @objc private func editProfileTapped() {
        coordinator?.didRequestEditProfile()
    }

    @objc private func privacyTapped() {
        showPrivacyAlert()
    }

    @objc private func aboutUsTapped() {
        showAboutUsAlert()
    }
}

// MARK: - Image picker
extension ProfileViewController {

    func showImageSourceAlert() {
        let alert = UIAlertController(
            title: "Change Profile Photo",
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentImagePicker(source: .photoLibrary)
        })

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentImagePicker(source: .camera)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func presentImagePicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            return
        }
        
        profileImageView.image = image
        viewModel.updateProfile(name: nil, email: nil, photo: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Alerts
extension ProfileViewController {

    func showPrivacyAlert() {
        showAlert(
            title: "Privacy",
            message: "Your data is stored locally and is not shared with third parties."
        )
    }

    func showAboutUsAlert() {
        showAlert(
            title: "About Us",
            message: "My Bookshelf helps you manage and discover books.\n\nVersion 1.0"
        )
    }
}
