//
//  Register.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

final class RegisterViewController: BaseController {

    weak var delegate: AuthFlowDelegate?

    // MARK: - UI
    private let logoImageView = LogoImageView()
    private let titleLabel = UILabel()

    private let nameField = GradientTextField.name(placeholder: "full name")
    private let emailField = GradientTextField.email(placeholder: "email")
    private let passwordField = GradientTextField.password(placeholder: "password")
    private let confirmPasswordField = GradientTextField.password(placeholder: "confirm password")

    private let registerButton = GradientButton.primary(title: "sign up", height: 52)
    private let loginButton = UIButton(type: .system)
    private let stack = UIStackView()

    // MARK: - UI Configuration
    override func configureUI() {
        view.backgroundColor = .appBackground

        titleLabel.text = "Create Account"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center

        stack.axis = .vertical
        stack.spacing = 12

        passwordField.textContentType = .newPassword

        loginButton.setTitle("Already have an account? Log In", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 14)
        loginButton.setTitleColor(.darkGreen, for: .normal)

        [nameField, emailField, passwordField, confirmPasswordField].forEach {
            $0.delegate = self
        }
        
        setupFieldNavigation([nameField, emailField, passwordField, confirmPasswordField])

        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }

    // MARK: - Constraints
    override func configureConstraints() {
        [logoImageView, titleLabel, stack, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [nameField, emailField, passwordField, confirmPasswordField, registerButton]
            .forEach { stack.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            loginButton.topAnchor.constraint(greaterThanOrEqualTo: stack.bottomAnchor, constant: 16),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
        
        [nameField, emailField, passwordField, confirmPasswordField].forEach { $0.setHeight(50) }
    }

    override func configureViewModel() {
        // no ViewModel yet
    }
}


private extension RegisterViewController {

    @objc func didTapRegister() {
         do {
             try AuthManager.shared.register(
                 email: emailField.text ?? "",
                 password: passwordField.text ?? ""
             )
             delegate?.didAuthenticate()
         } catch {
             showAlert(message: error.localizedDescription)
         }
     }
    
    @objc func didTapLogin() {
        navigationController?.popViewController(animated: true)
    }
}
