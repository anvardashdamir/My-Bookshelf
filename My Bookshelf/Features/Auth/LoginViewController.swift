//
//  Login.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit
import FirebaseAuth

protocol AuthFlowDelegate: AnyObject {
    func didAuthenticate()
    func didRequestLogout()
}

final class LoginViewController: BaseController {

    weak var delegate: AuthFlowDelegate?
    
    init(delegate: AuthFlowDelegate) {
          self.delegate = delegate
          super.init(nibName: nil, bundle: nil)
      }
    
    @available(*, unavailable)
       required init?(coder: NSCoder) {
           fatalError("init(coder:) is not supported")
       }

    // MARK: - UI
    private let logoImageView = LogoImageView()
    private let titleLabel = UILabel()
    private let emailField = GradientTextField.email(placeholder: "email")
    private let passwordField = GradientTextField.password(placeholder: "password")
    private let loginButton = GradientButton.primary(title: "login", height: 52)
    private let registerButton = UIButton(type: .system)
    private let stack = UIStackView()

    // MARK: - UI Configuration
    override func configureUI() {
        view.backgroundColor = .appBackground
        
        stack.axis = .vertical
        stack.spacing = 12
        
        setupFieldNavigation([emailField, passwordField])

        titleLabel.text = "Welcome to Bookshelf"
        titleLabel.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: 28)
        titleLabel.textAlignment = .center

        registerButton.setTitle("New here? Create an account", for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 14)
        registerButton.setTitleColor(.darkGreen, for: .normal)
        
        emailField.textContentType = .username
        emailField.returnKeyType = .next

        passwordField.textContentType = .password
        passwordField.returnKeyType = .done

        emailField.delegate = self
        passwordField.delegate = self

        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    // MARK: - Constraints
    override func configureConstraints() {
        [logoImageView, titleLabel, stack, registerButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [emailField, passwordField, loginButton].forEach {
            stack.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            registerButton.topAnchor.constraint(greaterThanOrEqualTo: stack.bottomAnchor, constant: 16),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
        
        [emailField, passwordField].forEach { $0.setHeight(50) }
    }

    // MARK: - ViewModel
    override func configureViewModel() {
        // no viewModel yet
    }
}

// MARK: - Actions
extension LoginViewController {

    @objc func didTapLogin() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(message: "Please enter email and password")
            return
        }
        
        guard let delegate = delegate else {
            showAlert(message: "Authentication error: Please restart the app")
            return
        }
        
        Task {
            do {
                print("🔄 Attempting login for: \(email)")
                try await AuthManager.shared.login(email: email, password: password)
                print("✅ Login successful!")
                
                guard let userId = AuthManager.shared.currentUserId else {
                    print("❌ ERROR: Login successful but currentUser is nil!")
                    await MainActor.run {
                        self.showAlert(message: "Login failed: Unable to get user ID")
                    }
                    return
                }
                
                print("   User ID: \(userId)")
                print("   Email: \(AuthManager.shared.currentUserEmail ?? "unknown")")
                
                print("🔄 Loading user profile from Firebase...")
                do {
                    let profile = try await FirebaseProfileService.shared.fetchProfile(userId: userId)
                    ProfileRepository.shared.updateProfile(
                        name: profile.name,
                        email: profile.email,
                        photo: nil
                    )
                    
                    // Load profile photo if exists
                    if let photoURL = profile.photoURL {
                        do {
                            if let photoData = try await FirebaseProfileService.shared.fetchProfilePhoto(urlString: photoURL) {
                                ProfileRepository.shared.updateProfile(name: nil, email: nil, photoData: photoData)
                            }
                        } catch {
                            print("⚠️ Could not load profile photo: \(error.localizedDescription)")
                        }
                    }
                    print("✅ Profile loaded from Firebase: \(profile.name)")
                } catch {
                    print("⚠️ Could not load profile from Firebase: \(error.localizedDescription)")
                }
                
                // Load saved books from Firebase
                print("🔄 Loading saved books from Firebase...")
                do {
                    let bookDTOs = try await FirebaseBooksService.shared.fetchBooks(uid: userId)
                    print("✅ Fetched \(bookDTOs.count) saved books")
                    
                    await MainActor.run {
                        ListsRepository.shared.replaceAll(with: bookDTOs)
                    }
                } catch {
                    print("⚠️ Could not load books from Firebase: \(error.localizedDescription)")
                }
                
                await MainActor.run {
                    delegate.didAuthenticate()
                }
            } catch {
                print("❌ Login error: \(error.localizedDescription)")
                await MainActor.run {
                    self.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc func didTapRegister() {
        let vc = RegisterViewController(delegate: delegate!)
        navigationController?.pushViewController(vc, animated: true)
    }
}
