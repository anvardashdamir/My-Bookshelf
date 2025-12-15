//
//  Login.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func didCompleteLogin()
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginViewControllerDelegate?

    // MARK: - UI
    private let logoImageView = LogoImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Bookshelf"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailField: GradientTextField = {
        let tf = GradientTextField.email(placeholder: "email")
        tf.textContentType = .username
        return tf
    }()
    
    private let passwordField: GradientTextField = {
        let tf = GradientTextField.password(placeholder: "password")
        tf.textContentType = .password
        return tf
    }()

    private let loginButton = GradientButton.primary(title: "login", height: 52)

    private let registerPromptButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("New here? Create an account", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.darkGreen, for: .normal)
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
        view.backgroundColor = .appBackground
        setupLayout()
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerPromptButton.addTarget(self, action: #selector(didTapRegisterPrompt), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(stack)
        view.addSubview(registerPromptButton)

        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(passwordField)
        stack.addArrangedSubview(loginButton)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            emailField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50),

            registerPromptButton.topAnchor.constraint(greaterThanOrEqualTo: stack.bottomAnchor, constant: 16),
            registerPromptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerPromptButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
    }

    // MARK: - Actions
    @objc private func didTapLogin() {
        view.endEditing(true)
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""

        guard isValidEmail(email) else {
            showAlert(message: "Please enter a valid email.")
            return
        }
        guard !password.isEmpty else {
            showAlert(message: "Please enter your password.")
            return
        }

        do {
            try AuthManager.shared.login(email: email, password: password)
            print("Successful login!")
            switchToMainInterface()
        } catch {
            showAlert(message: error.localizedDescription)
        }
    }

    @objc private func didTapRegisterPrompt() {
        let vc = RegisterViewController()
        vc.delegate = delegate
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(UINavigationController(rootViewController: vc), animated: true)
        }
    }

    // MARK: - Navigation
    private func switchToMainInterface() {
        delegate?.didCompleteLogin()
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
