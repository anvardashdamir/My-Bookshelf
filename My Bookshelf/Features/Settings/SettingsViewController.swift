//
//  SettingsViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    private var profile: ProfileManager { .shared }
    private let imagePicker = UIImagePickerController()

    // MARK: - UI -
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // Profile card
    private let profileCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray4
//        iv.layer.cornerRadius = 40
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let editButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Edit profile", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        b.setTitleColor(.systemBlue, for: .normal)
        b.isUserInteractionEnabled = true
        return b
    }()
    
    private let appearanceCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()

    private let darkModeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Interface Regime"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()

    private let darkModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = .systemBlue
        return toggle
    }()

    private let infoCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()
    
    private let privacyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Privacy", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let aboutUsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("About Us", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground

        setupHierarchy()
        setupLayout()
        setupDarkModeInitialState()
        setupActions()
        loadProfileData()
        setupImagePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    
    // MARK: - Setup -
    private func setupHierarchy() {
        view.addSubview(scrollView)
        view.addSubview(logoutButton)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(profileCard)
        contentStack.addArrangedSubview(appearanceCard)
        contentStack.addArrangedSubview(infoCard)

        profileCard.addSubview(profileImageView)
        profileCard.addSubview(nameLabel)
        profileCard.addSubview(emailLabel)
        profileCard.addSubview(editButton)

        appearanceCard.addSubview(darkModeLabel)
        appearanceCard.addSubview(darkModeSwitch)
        
        // Privacy & About Us
        infoCard.addSubview(privacyButton)
        infoCard.addSubview(separatorView)
        infoCard.addSubview(aboutUsButton)
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
    }
    
    private func loadProfileData() {
        nameLabel.text = profile.userName
        emailLabel.text = profile.userEmail
        profileImageView.image = profile.profilePhoto
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -20),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            logoutButton.heightAnchor.constraint(equalToConstant: 56),

            profileCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            profileImageView.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: profileCard.topAnchor, constant: 16),
            profileImageView.bottomAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: -16),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -16),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            editButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            editButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            editButton.bottomAnchor.constraint(lessThanOrEqualTo: profileCard.bottomAnchor, constant: -8),

            appearanceCard.heightAnchor.constraint(equalToConstant: 56),
            darkModeLabel.centerYAnchor.constraint(equalTo: appearanceCard.centerYAnchor),
            darkModeLabel.leadingAnchor.constraint(equalTo: appearanceCard.leadingAnchor, constant: 16),

            darkModeSwitch.centerYAnchor.constraint(equalTo: appearanceCard.centerYAnchor),
            darkModeSwitch.trailingAnchor.constraint(equalTo: appearanceCard.trailingAnchor, constant: -16),
            
            // Privacy & About Us | 56 * 2 for two rows
            infoCard.heightAnchor.constraint(equalToConstant: 112),
            
            privacyButton.topAnchor.constraint(equalTo: infoCard.topAnchor),
            privacyButton.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            privacyButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            privacyButton.heightAnchor.constraint(equalToConstant: 56),
            
            separatorView.topAnchor.constraint(equalTo: privacyButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            aboutUsButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            aboutUsButton.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            aboutUsButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            aboutUsButton.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor),
            aboutUsButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupDarkModeInitialState() {
        if let savedStyle = UserDefaults.standard.string(forKey: "userInterfaceStyle") {
            let isDarkMode = savedStyle == "dark"
            darkModeSwitch.isOn = isDarkMode
        } else {
            darkModeSwitch.isOn = traitCollection.userInterfaceStyle == .dark
        }
    }

    private func setupActions() {
        darkModeSwitch.addTarget(self, action: #selector(darkModeSwitchChanged(_:)), for: .valueChanged)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        // Profile image tap
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(imageTap)
        
        // Edit label tap
        editButton.addTarget(self, action: #selector(editLabelTapped), for: .touchUpInside)
        
        // Privacy button
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        
        // About Us button
        aboutUsButton.addTarget(self, action: #selector(aboutUsTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func darkModeSwitchChanged(_ sender: UISwitch) {
        let style: UIUserInterfaceStyle = sender.isOn ? .dark : .light

        UserDefaults.standard.set(sender.isOn ? "dark" : "light", forKey: "userInterfaceStyle")
        
        if let windowScene = view.window?.windowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        }
    }


    @objc private func profileImageTapped() {
        showImageSourceAlert()
    }
    
    @objc private func editLabelTapped() {
        showEditProfileAlert()
    }
    
    @objc private func privacyTapped() {
        showPrivacyAlert()
    }
    
    @objc private func aboutUsTapped() {
        showAboutUsAlert()
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            AuthManager.shared.logout()
            // Navigate back to login screen
            guard let sceneDelegate = self?.view.window?.windowScene?.delegate as? SceneDelegate else { return }
            sceneDelegate.startLoginFlow()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Image Picker
    private func showImageSourceAlert() {
        let alert = UIAlertController(title: "Change Profile Photo", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.imagePicker.sourceType = .photoLibrary
            guard let self else { return }
            self.present(self.imagePicker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            guard let self else { return }
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.showAlert(message: "Camera not available")
                return
            }
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
        present(alert, animated: true)
    }
    
    // MARK: - Edit Profile
    private func showEditProfileAlert() {
        let alert = UIAlertController(title: "Edit Profile", message: nil, preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Name"
            textField.text = ProfileManager.shared.userName
        }
        
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
            textField.text = ProfileManager.shared.userEmail
        }
                
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let nameField = alert.textFields?[0],
                  let emailField = alert.textFields?[1] else { return }
            
            let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            if !name.isEmpty {
                ProfileManager.shared.userName = name
            }
            if !email.isEmpty {
                ProfileManager.shared.userEmail = email
            }
            
            self?.loadProfileData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Privacy
    private func showPrivacyAlert() {
        let alert = UIAlertController(
            title: "Privacy",
            message: "We respect your privacy. Your personal data, including your reading lists and preferences, are stored locally on your device. We do not collect or share your personal information with third parties.\n\nFor more information, please review our Privacy Policy.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - About Us
    private func showAboutUsAlert() {
        let alert = UIAlertController(
            title: "About Us",
            message: "My Bookshelf is a modern app for managing your personal book collection. Discover new books, organize your reading lists, and keep track of your favorite titles.\n\nVersion 1.0",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profile.profilePhoto = editedImage
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profile.profilePhoto = originalImage
            profileImageView.image = originalImage
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
