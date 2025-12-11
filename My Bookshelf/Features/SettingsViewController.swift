//
//  SettingsViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

final class SettingsViewController: UIViewController {

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
        stack.distribution = .equalSpacing
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
        iv.layer.cornerRadius = 40
        iv.backgroundColor = .systemGray4
        iv.image = UIImage(named: "profile_photo")
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.text = "John Smith"
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.text = "john.smith@example.com"
        return label
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

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground

        setupHierarchy()
        setupLayout()
        setupDarkModeInitialState()
        setupActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
    }

    // MARK: - Setup
    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        // Add cards + button into stack
        contentStack.addArrangedSubview(profileCard)
        contentStack.addArrangedSubview(appearanceCard)
        contentStack.addArrangedSubview(logoutButton)

        // Profile card content
        profileCard.addSubview(profileImageView)
        profileCard.addSubview(nameLabel)
        profileCard.addSubview(emailLabel)

        // Appearance card content
        appearanceCard.addSubview(darkModeLabel)
        appearanceCard.addSubview(darkModeSwitch)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Stack inside scroll
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),

            // Profile card height (dynamic but min)
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
            emailLabel.bottomAnchor.constraint(lessThanOrEqualTo: profileCard.bottomAnchor, constant: -8),

            // Appearance card
            appearanceCard.heightAnchor.constraint(equalToConstant: 56),
            darkModeLabel.centerYAnchor.constraint(equalTo: appearanceCard.centerYAnchor),
            darkModeLabel.leadingAnchor.constraint(equalTo: appearanceCard.leadingAnchor, constant: 16),

            darkModeSwitch.centerYAnchor.constraint(equalTo: appearanceCard.centerYAnchor),
            darkModeSwitch.trailingAnchor.constraint(equalTo: appearanceCard.trailingAnchor, constant: -16),

            // Logout button
            logoutButton.heightAnchor.constraint(equalToConstant: 48)
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

    

    @objc private func logoutTapped() {
        print("Logout tapped")
    }
}
