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

        // Edit profile icon
        editIconButton.addTarget(
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
            do {
                try self?.viewModel.logout()
                self?.authDelegate?.didRequestLogout()
            } catch {
                self?.showAlert(message: "Logout failed: \(error.localizedDescription)")
            }
        })

        present(alert, animated: true)
    }

    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "This action cannot be undone. All your data will be permanently deleted.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.attemptDeleteAccount(password: nil)
        })

        present(alert, animated: true)
    }
    
    private func attemptDeleteAccount(password: String?) {
        Task {
            do {
                try await viewModel.deleteAccount(passwordForReauth: password)
                await MainActor.run {
                    self.authDelegate?.didRequestLogout()
                }
            } catch {
                await MainActor.run {
                    if case AuthError.requiresRecentLogin = error {
                        self.showReauthenticationAlert()
                    } else {
                        self.showAlert(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func showReauthenticationAlert() {
        let alert = UIAlertController(
            title: "Confirm Password",
            message: "For security, please enter your password to confirm account deletion.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            textField.textContentType = .password
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let password = alert.textFields?.first?.text, !password.isEmpty else {
                self?.showAlert(message: "Password is required")
                return
            }
            self?.attemptDeleteAccount(password: password)
        })
        
        present(alert, animated: true)
    }
    

    @objc private func profileImageTapped() {
        showImageSourceAlert()
    }

    @objc private func editProfileTapped() {
        let alert = UIAlertController(
            title: "Edit Name",
            message: "Enter your new name",
            preferredStyle: .alert
        )
        
        alert.addTextField { [weak self] textField in
            textField.text = self?.viewModel.userName
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let newName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty else {
                return
            }
            
            self?.viewModel.updateProfile(name: newName, email: nil, photo: nil)
            self?.renderProfile()
        })
        
        present(alert, animated: true)
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
        
        // Upload to Firebase Storage and update Firestore
        Task {
            guard let userId = AuthManager.shared.currentUserId else {
                await MainActor.run {
                    self.showAlert(message: "Unable to upload photo: User not authenticated")
                }
                return
            }
            
            do {
                // Upload to Storage
                let photoURL = try await FirebaseProfileService.shared.uploadProfilePhoto(image, userId: userId)
                print("✅ Profile photo uploaded: \(photoURL)")
                
                // Update Firestore profile with photoURL
                let currentProfile = try await FirebaseProfileService.shared.fetchProfile(userId: userId)
                var updatedProfile = currentProfile
                updatedProfile.photoURL = photoURL
                try await FirebaseProfileService.shared.saveProfile(updatedProfile, userId: userId)
                print("✅ Profile updated with photoURL")
                
                // Update local ProfileManager
                await MainActor.run {
                    self.viewModel.updateProfile(name: nil, email: nil, photo: image)
                }
            } catch {
                print("❌ Error uploading profile photo: \(error.localizedDescription)")
                await MainActor.run {
                    self.showAlert(message: "Failed to upload photo: \(error.localizedDescription)")
                }
            }
        }
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
