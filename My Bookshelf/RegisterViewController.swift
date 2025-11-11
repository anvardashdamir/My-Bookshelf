//
//  Register.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

class RegisterViewController: UIViewController {

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full name"
        tf.autocapitalizationType = .words
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .next
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.textContentType = .emailAddress
        tf.returnKeyType = .next
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.textContentType = .newPassword
        tf.returnKeyType = .next
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let confirmPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm password"
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.textContentType = .newPassword
        tf.returnKeyType = .done
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 10
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let loginPromptButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Already have an account? Log In", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Register"
        setupLayout()
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        loginPromptButton.addTarget(self, action: #selector(didTapLoginPrompt), for: .touchUpInside)
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(stack)
        view.addSubview(loginPromptButton)

        stack.addArrangedSubview(nameField)
        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(passwordField)
        stack.addArrangedSubview(confirmPasswordField)
        stack.addArrangedSubview(registerButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            registerButton.heightAnchor.constraint(equalToConstant: 48),

            loginPromptButton.topAnchor.constraint(greaterThanOrEqualTo: stack.bottomAnchor, constant: 16),
            loginPromptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginPromptButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
    }

    // MARK: - Actions
    @objc private func didTapRegister() {
        view.endEditing(true)
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""
        let confirm = confirmPasswordField.text ?? ""

        guard !name.isEmpty else { showAlert(message: "Please enter your name."); return }
        guard isValidEmail(email) else { showAlert(message: "Please enter a valid email."); return }
        guard password.count >= 6 else { showAlert(message: "Password must be at least 6 characters."); return }
        guard password == confirm else { showAlert(message: "Passwords do not match."); return }

        // TODO: Hook up to your auth backend
        showAlert(title: "Success", message: "Account created (mock)")
    }

    @objc private func didTapLoginPrompt() {
        // Navigate to Login screen
        let vc = LoginViewController()
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(UINavigationController(rootViewController: vc), animated: true)
        }
    }

    // MARK: - Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: email.utf16.count)
        let matches = detector?.matches(in: email, options: [], range: range) ?? []
        return matches.count == 1 && matches.first?.url?.scheme == "mailto" && matches.first?.range == range
    }

    private func showAlert(title: String = "", message: String) {
        let ac = UIAlertController(title: title.isEmpty ? nil : title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmPasswordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
