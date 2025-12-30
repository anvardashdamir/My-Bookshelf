//
//  Login.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

protocol AuthFlowDelegate: AnyObject {
    func didAuthenticate()
    func didRequestLogout()
}

final class LoginViewController: BaseController {

    weak var delegate: AuthFlowDelegate?

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
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
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
        do {
            try AuthManager.shared.login(
                email: emailField.text ?? "",
                password: passwordField.text ?? ""
            )
            delegate?.didAuthenticate()
        } catch {
            showAlert(message: error.localizedDescription)
        }
    }

    @objc func didTapRegister() {
        let vc = RegisterViewController()
        vc.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }
}
