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
    weak var authDelegate: AuthFlowDelegate?
    let viewModel: ProfileViewModel
    
    init() {
        self.viewModel = ProfileViewModel(
            authManager: AuthManager.shared,
            profileRepository: ProfileRepository.shared,
            firebaseProfileService: FirebaseProfileService.shared
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = ProfileViewModel(
            authManager: AuthManager.shared,
            profileRepository: ProfileRepository.shared,
            firebaseProfileService: FirebaseProfileService.shared
        )
        super.init(coder: coder)
    }
    
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
        v.backgroundColor = .card
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
        label.textAlignment = .left
        return label
    }()

    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    let editIconButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        b.tintColor = .systemBlue
        return b
    }()
    
    // Appearance
    let appearanceCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .card
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
        v.backgroundColor = .card
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
        loadProfileFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileFromFirebase()
    }
    
    private func loadProfileFromFirebase() {
        Task {
            do {
                try await viewModel.loadProfileFromFirebase()
                await MainActor.run {
                    self.renderProfile()
                }
            } catch {
                print("⚠️ Error loading profile: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Rendering
    func renderProfile() {
        nameLabel.text = viewModel.userName
        emailLabel.text = viewModel.userEmail
        
        if let imageData = viewModel.profileImageData,
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}

// MARK: - UI setup
private extension ProfileViewController {
    
    func setupAppearance() {
        title = "Profile"
        view.backgroundColor = .appBackground
        
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
        profileCard.addSubview(editIconButton)

        appearanceCard.addSubview(darkModeLabel)
        appearanceCard.addSubview(darkModeSwitch)
        
        infoCard.addSubview(privacyButton)
        infoCard.addSubview(separatorView)
        infoCard.addSubview(aboutUsButton)
    }
    
    func setupLayout() {
        // Better scroll sizing
        let contentLayout = scrollView.contentLayoutGuide
        let frameLayout = scrollView.frameLayoutGuide

        // Card paddings
        let cardInset: CGFloat = 16

        // Prepare buttons
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        aboutUsButton.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        darkModeLabel.translatesAutoresizingMaskIntoConstraints = false
        darkModeSwitch.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        editIconButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: deleteAccountButton.topAnchor, constant: -16),

            // Content stack in scroll
            contentStack.topAnchor.constraint(equalTo: contentLayout.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor, constant: -20),

            // Critical: content width == scroll frame width (prevents weird horizontal sizing)
            contentStack.widthAnchor.constraint(equalTo: frameLayout.widthAnchor, constant: -40),

            // Bottom buttons
            deleteAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteAccountButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -12),
            
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

        // MARK: - Profile Card Layout
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        let cardBottomPadding: CGFloat = 60

        NSLayoutConstraint.activate([
            // Image on the left with top padding
            profileImageView.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: profileCard.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            // Name label on the right of image
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: profileCard.topAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: editIconButton.leadingAnchor, constant: -8),

            // Edit icon button to the right of name
            editIconButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            editIconButton.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -cardInset),
            editIconButton.widthAnchor.constraint(equalToConstant: 24),
            editIconButton.heightAnchor.constraint(equalToConstant: 24),

            // Email label below name
            emailLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -cardInset),
            emailLabel.bottomAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: -cardBottomPadding)
        ])

        // Fix corner radius after size
        profileImageView.layer.cornerRadius = 40

        // MARK: - Appearance Card Layout (label + switch)
        NSLayoutConstraint.activate([
            darkModeLabel.topAnchor.constraint(equalTo: appearanceCard.topAnchor, constant: cardInset),
            darkModeLabel.leadingAnchor.constraint(equalTo: appearanceCard.leadingAnchor, constant: cardInset),
            darkModeLabel.bottomAnchor.constraint(equalTo: appearanceCard.bottomAnchor, constant: -cardInset),

            darkModeSwitch.centerYAnchor.constraint(equalTo: darkModeLabel.centerYAnchor),
            darkModeSwitch.trailingAnchor.constraint(equalTo: appearanceCard.trailingAnchor, constant: -cardInset),
            darkModeSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: darkModeLabel.trailingAnchor, constant: 12)
        ])

        // MARK: - Info Card Layout (2 rows)
        NSLayoutConstraint.activate([
            privacyButton.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 6),
            privacyButton.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: cardInset),
            privacyButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -cardInset),
            privacyButton.heightAnchor.constraint(equalToConstant: 44),
            
            separatorView.topAnchor.constraint(equalTo: privacyButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: cardInset),
            separatorView.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -cardInset),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            aboutUsButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            aboutUsButton.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: cardInset),
            aboutUsButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -cardInset),
            aboutUsButton.heightAnchor.constraint(equalToConstant: 44),
            aboutUsButton.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -6),
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
