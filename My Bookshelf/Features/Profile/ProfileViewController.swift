//
//  ProfileViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit
import FirebaseAuth

// MARK: - Flow delegate
protocol ProfileFlowDelegate: AnyObject {
    func didRequestLogout()
    func didRequestAccountDeletion()
    func didRequestEditProfile()
}

final class ProfileViewController: BaseController {
    
    // MARK: - Dependencies
    weak var coordinator: ProfileFlowDelegate?
    let viewModel = ProfileViewModel()
    
    // MARK: - UI
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        return sv
    }()
    
    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Profile card
    let profileCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        return v
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40
        iv.backgroundColor = .systemGray4
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    let editButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Edit profile", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return b
    }()
    
    // Appearance
    let appearanceCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        return v
    }()
    
    let darkModeLabel: UILabel = {
        let label = UILabel()
        label.text = "Interface Regime"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    let darkModeSwitch: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .systemBlue
        return s
    }()
    
    // Info
    let infoCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        return v
    }()
    
    let privacyButton = UIButton(type: .system)
    let aboutUsButton = UIButton(type: .system)
    
    let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        return v
    }()
    
    let deleteAccountButton = GradientButton.destructive(
        title: "Delete Account",
        height: 48
    )
    
    let logoutButton = GradientButton.destructive(
        title: "Log Out",
        height: 48
    )
    
    // MARK: - Lifecycle
    override func configureUI() {
        setupAppearance()
        setupDarkModeInitialState()
        setupHierarchy()
        setupActions()
    }
    
    override func configureConstraints() {
        setupLayout()
    }
    
    override func configureViewModel() {
        renderProfile()
    }
    
    // MARK: - Rendering
    private func renderProfile() {
        nameLabel.text = viewModel.userName
        emailLabel.text = viewModel.userEmail
        profileImageView.image = viewModel.profileImage
    }
}

// MARK: - UI setup
private extension ProfileViewController {
    
    func setupAppearance() {
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        privacyButton.setTitle("Privacy", for: .normal)
        privacyButton.contentHorizontalAlignment = .left
        
        aboutUsButton.setTitle("About Us", for: .normal)
        aboutUsButton.contentHorizontalAlignment = .left
    }
    
    func setupHierarchy() {
        view.addSubview(scrollView)
        view.addSubview(deleteAccountButton)
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
        
        infoCard.addSubview(privacyButton)
        infoCard.addSubview(separatorView)
        infoCard.addSubview(aboutUsButton)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: deleteAccountButton.topAnchor, constant: -20),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            deleteAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteAccountButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -12),
            
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
}

// MARK: - Actions
private extension ProfileViewController {
    
    func setupDarkModeInitialState() {
        let saved = UserDefaults.standard.string(forKey: "userInterfaceStyle")
        darkModeSwitch.isOn = saved == "dark"
    }
}
