//
//  Register.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

class RegisterViewController: UIViewController {
    
    weak var delegate: LoginViewControllerDelegate?

    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameField = GradientTextField.name(placeholder: "Full name")
    
    private let emailField = GradientTextField.email(placeholder: "Email")
    
    private let passwordField: GradientTextField = {
        let tf = GradientTextField.password(placeholder: "Password")
        tf.textContentType = .newPassword
        tf.returnKeyType = .next
        return tf
    }()
    
    private let confirmPasswordField = GradientTextField.password(placeholder: "Confirm password")

    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 16
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

            nameField.heightAnchor.constraint(equalToConstant: 50),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 50),
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

        guard !name.isEmpty else {
            showAlert(message: "Please enter your name.")
            return
        }
        guard isValidEmail(email) else {
            showAlert(message: "Please enter a valid email.")
            return
        }
        guard password.count >= 6 else {
            showAlert(message: "Password must be at least 6 characters.")
            return
        }
        guard password == confirm else {
            showAlert(message: "Passwords do not match.")
            return
        }

        do {
            try AuthManager.shared.register(email: email, password: password)
            // Save user name to profile
            ProfileManager.shared.userName = name
            ProfileManager.shared.userEmail = email
            print("Registered & logged in as \(email)")
            switchToMainInterface()
        } catch {
            showAlert(message: error.localizedDescription)
        }
    }
    
    @objc private func didTapLoginPrompt() {
        // Works for both push and modal
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    private func switchToMainInterface() {
        // Pass delegate from LoginViewController if available
        if let loginVC = navigationController?.viewControllers.first as? LoginViewController {
            loginVC.delegate?.didCompleteLogin()
        } else {
            // Fallback: directly access SceneDelegate
            guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
            sceneDelegate.startMainApp()
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
        let ac = UIAlertController(title: title.isEmpty ? nil : title,
                                   message: message,
                                   preferredStyle: .alert)
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
