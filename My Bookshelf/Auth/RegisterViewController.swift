//
//  Register.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 11.11.25.
//

import UIKit
import FirebaseAuth

/**
 * RegisterViewController: UI screen for user registration
 *
 * RESPONSIBILITIES:
 * - Displays registration form (name, email, password, confirm password)
 * - Validates user input (email format, password strength, matching passwords)
 * - Creates new user account via AuthManager
 * - Saves user profile to Firebase Firestore
 * - Navigates to main app after successful registration
 *
 * INHERITS FROM: UIViewController (base class for all iOS screens)
 */
class RegisterViewController: UIViewController {
    
    /**
     * DELEGATE PATTERN: weak reference to LoginViewController
     * 
     * WHAT IT DOES: Allows communication back to LoginViewController
     *               (e.g., "registration complete, switch to main app")
     * 
     * weak: Prevents memory leaks (doesn't create strong reference cycle)
     * Optional (?): Can be nil if no delegate is set
     */
    weak var delegate: LoginViewControllerDelegate?

    // MARK: - UI Components
    
    /**
     * UI PROPERTIES: All UI elements are stored as properties
     * 
     * private: Only accessible within this class
     * let: Immutable (cannot be reassigned after initialization)
     * 
     * CLOSURE INITIALIZATION: { }() creates and configures the view immediately
     * WHY: Keeps configuration code close to declaration (better organization)
     */
    
    private let logoImageView = LogoImageView()
    
    /**
     * Title label - shows "Create Account" at top of screen
     * CLOSURE SYNTAX: { }() - immediately executes the closure
     * Returns: Configured UILabel instance
     */
    private let titleLabel: UILabel = {
        let label = UILabel() // Create new UILabel
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 28, weight: .bold) // Bold, 28pt font
        label.textAlignment = .center // Center the text
        label.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        return label // Return configured label
    }()

    /**
     * Text fields for user input
     * Using custom GradientTextField class with factory methods
     */
    private let nameField = GradientTextField.name(placeholder: "full name")
    private let emailField = GradientTextField.email(placeholder: "email")
    
    /**
     * Password field with special configuration
     * textContentType: .newPassword - tells iOS this is for new password (enables password suggestions)
     * returnKeyType: .next - shows "Next" button on keyboard
     */
    private let passwordField: GradientTextField = {
        let tf = GradientTextField.password(placeholder: "password")
        tf.textContentType = .newPassword // iOS password manager integration
        tf.returnKeyType = .next // Keyboard shows "Next" button
        return tf
    }()
    
    private let confirmPasswordField = GradientTextField.password(placeholder: "confirm password")

    /**
     * Register button - triggers registration when tapped
     * Using custom GradientButton with factory method
     */
    private let registerButton = GradientButton.primary(title: "sign up", height: 52)

    /**
     * Button to navigate to login screen
     * type: .system - iOS system button style
     */
    private let loginPromptButton: UIButton = {
        let btn = UIButton(type: .system) // System button style
        btn.setTitle("Already have an account? Log In", for: .normal) // Normal state text
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.darkGreen, for: .normal) // Custom green color
        btn.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        return btn
    }()

    /**
     * UIStackView: Container that arranges views vertically
     * 
     * WHAT IT DOES: Automatically arranges child views in a stack
     * axis: .vertical - stacks views top to bottom
     * spacing: 12 - 12 points between each view
     * 
     * WHY USE IT: Simplifies layout - no need to manually position each view
     */
    private let stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical // Stack vertically (top to bottom)
        sv.spacing = 12 // 12 points between items
        sv.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        return sv
    }()

    // MARK: - Lifecycle Methods
    
    /**
     * viewDidLoad: Called once when the view controller's view is loaded into memory
     * 
     * WHAT IT DOES:
     * 1. Sets up the view's background color
     * 2. Configures Auto Layout constraints
     * 3. Connects button actions (what happens when buttons are tapped)
     * 4. Sets text field delegates (handles keyboard return key)
     * 
     * override: This method exists in UIViewController, we're customizing it
     * super.viewDidLoad(): Calls parent class implementation first
     */
    override func viewDidLoad() {
        super.viewDidLoad() // Call parent implementation
        view.backgroundColor = .appBackground // Set custom background color
        setupLayout() // Configure all Auto Layout constraints
        // TARGET-ACTION PATTERN: Connect button taps to methods
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        loginPromptButton.addTarget(self, action: #selector(didTapLoginPrompt), for: .touchUpInside)
        // DELEGATE PATTERN: Handle text field events (keyboard return key, etc.)
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(stack)
        view.addSubview(loginPromptButton)

        stack.addArrangedSubview(nameField)
        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(passwordField)
        stack.addArrangedSubview(confirmPasswordField)
        stack.addArrangedSubview(registerButton)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            nameField.heightAnchor.constraint(equalToConstant: 50),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 50),

            loginPromptButton.topAnchor.constraint(greaterThanOrEqualTo: stack.bottomAnchor, constant: 16),
            loginPromptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginPromptButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
    }

    // MARK: - Action Methods
    
    /**
     * didTapRegister: Called when user taps the "Sign Up" button
     * 
     * @objc: Required for Target-Action pattern (allows method to be called by button)
     * 
     * WHAT IT DOES:
     * 1. Dismisses keyboard
     * 2. Extracts and validates user input
     * 3. Performs validation checks
     * 4. Creates Firebase Auth user
     * 5. Saves profile to Firestore
     * 6. Navigates to main app
     */
    @objc private func didTapRegister() {
        // Dismiss keyboard when button is tapped
        view.endEditing(true)
        
        /**
         * EXTRACTING USER INPUT:
         * - text?: Optional String (nil if empty)
         * - trimmingCharacters: Removes whitespace from start/end
         * - ?? "": Nil coalescing - use empty string if nil
         */
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""
        let confirm = confirmPasswordField.text ?? ""

        /**
         * VALIDATION CHECKS using guard statements
         * 
         * guard: Early exit if condition fails
         * - If condition is false, execute code in else block (return)
         * - If condition is true, continue to next line
         * 
         * WHY USE guard: Makes validation code cleaner and more readable
         */
        guard !name.isEmpty else {
            showAlert(message: "Please enter your name.")
            return // Exit function early
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

        /**
         * ASYNC REGISTRATION: Task creates a new async context
         * 
         * Task: Wraps async code so it can run concurrently
         * WHY: UI code (this function) is synchronous, but registration is async
         * 
         * do-catch: Error handling block
         * - try: Marks code that can throw errors
         * - catch: Handles any errors that occur
         */
        Task {
            do {
                print("🔄 Starting registration for: \(email)")
                
                /**
                 * STEP 1: Create Firebase Auth user
                 * - await: Pauses here until Firebase responds (non-blocking)
                 * - try: Can throw errors (handled in catch block)
                 * - Creates user in Firebase Authentication Console
                 */
                try await AuthManager.shared.register(email: email, password: password)
                
                /**
                 * STEP 2: Verify user was created and get User ID
                 * - guard: Ensures we have a user ID before continuing
                 * - Auth.auth().currentUser: The currently authenticated Firebase user
                 * - .uid: Unique identifier for this user
                 */
                guard let userId = Auth.auth().currentUser?.uid else {
                    print("❌ ERROR: Firebase Auth user created but currentUser is nil!")
                    throw NSError(domain: "RegisterViewController", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID after registration"])
                }
                
                print("✅ Firebase Auth user created successfully!")
                print("   User ID: \(userId)")
                print("   Email: \(Auth.auth().currentUser?.email ?? "unknown")")
                
                /**
                 * STEP 3: Save profile data to Firebase Firestore
                 * - UserProfile: Struct containing name, email, photoURL
                 * - saveProfile: Async function that saves to Firestore database
                 * - Firestore path: users/{userId}/data/profile
                 */
                let profile = UserProfile(name: name, email: email, photoURL: nil)
                try await FirebaseProfileService.shared.saveProfile(profile, userId: userId)
                print("✅ Profile saved to Firestore")
                
                /**
                 * STEP 4: Save locally for backward compatibility
                 * - ProfileManager: Manages local UserDefaults storage
                 * - Allows app to work even if Firebase is temporarily unavailable
                 */
                ProfileManager.shared.userName = name
                ProfileManager.shared.userEmail = email
                
                print("✅ Registration complete for: \(email)")
                
                /**
                 * STEP 5: Navigate to main app (must be on main thread)
                 * - MainActor.run: Ensures UI updates happen on main thread
                 * - WHY: All UI operations must be on main thread in iOS
                 */
                await MainActor.run {
                    self.switchToMainInterface()
                }
            } catch {
                /**
                 * ERROR HANDLING: Log detailed error info for debugging
                 */
                print("❌ Registration error:")
                print("   Error: \(error)")
                print("   Description: \(error.localizedDescription)")
                
                /**
                 * TYPE CASTING: Convert error to NSError to access more details
                 * - if let: Optional binding - only executes if cast succeeds
                 * - as NSError?: Attempts to cast error to NSError type
                 */
                if let nsError = error as NSError? {
                    print("   Domain: \(nsError.domain)") // Error category
                    print("   Code: \(nsError.code)") // Specific error code
                    print("   UserInfo: \(nsError.userInfo)") // Additional error info
                }
                
                /**
                 * Show user-friendly error message
                 * - MainActor: Ensures UI update happens on main thread
                 */
                await MainActor.run {
                    var errorMessage = error.localizedDescription
                    
                    /**
                     * ERROR CODE MAPPING: Convert Firebase error codes to user-friendly messages
                     * - Pattern matching on error domain and code
                     * - Provides specific messages for common errors
                     */
                    if let nsError = error as NSError?,
                       nsError.domain == "FIRAuthErrorDomain" {
                        switch nsError.code {
                        case 17007: // Email already in use
                            errorMessage = "This email is already registered."
                        case 17008: // Invalid email
                            errorMessage = "Invalid email format."
                        case 17026: // Weak password
                            errorMessage = "Password is too weak. Please use a stronger password."
                        default:
                            errorMessage = "Registration failed: \(error.localizedDescription)"
                        }
                    }
                    
                    self.showAlert(message: errorMessage)
                }
            }
        }
    }
    
    /**
     * didTapLoginPrompt: Navigates back to login screen
     * 
     * HANDLES TWO SCENARIOS:
     * 1. If in navigation stack: Pop (go back)
     * 2. If presented modally: Dismiss (close modal)
     */
    @objc private func didTapLoginPrompt() {
        // Works for both push and modal presentation
        if let nav = navigationController, nav.viewControllers.first != self {
            // In navigation stack - pop (go back)
            nav.popViewController(animated: true)
        } else {
            // Presented modally - dismiss (close)
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation Methods
    
    /**
     * switchToMainInterface: Navigates to main app after successful registration
     * 
     * DELEGATE PATTERN: Tries to notify LoginViewController first
     * FALLBACK: Directly accesses SceneDelegate if delegate not available
     */
    private func switchToMainInterface() {
        // Try to use delegate (if RegisterViewController was pushed from LoginViewController)
        if let loginVC = navigationController?.viewControllers.first as? LoginViewController {
            loginVC.delegate?.didCompleteLogin() // Notify delegate
        } else {
            // Fallback: directly access SceneDelegate
            // TYPE CASTING: as? SceneDelegate - safely casts to SceneDelegate type
            guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
            sceneDelegate.startMainApp() // Start main app directly
        }
    }
    
    // MARK: - Helper Methods
    
    /**
     * isValidEmail: Validates email format using NSDataDetector
     * 
     * PARAMETER: email - String to validate
     * RETURNS: Bool - true if valid email format
     * 
     * HOW IT WORKS:
     * 1. Uses NSDataDetector to find email patterns
     * 2. Checks if exactly one match found
     * 3. Verifies match is "mailto:" scheme
     * 4. Ensures match covers entire string
     */
    private func isValidEmail(_ email: String) -> Bool {
        // NSDataDetector: iOS class that finds patterns in text (emails, URLs, etc.)
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        // NSRange: Represents a range of characters (location, length)
        let range = NSRange(location: 0, length: email.utf16.count)
        // Find all matches in the email string
        let matches = detector?.matches(in: email, options: [], range: range) ?? []
        // Valid if: exactly 1 match, scheme is "mailto", and match covers entire string
        return matches.count == 1 && matches.first?.url?.scheme == "mailto" && matches.first?.range == range
    }

    /**
     * showAlert: Displays an alert dialog to the user
     * 
     * PARAMETERS:
     * - title: Optional alert title (defaults to empty string)
     * - message: Required alert message
     * 
     * UIAlertController: iOS class for showing alerts
     * - preferredStyle: .alert - shows as centered popup
     */
    private func showAlert(title: String = "", message: String) {
        let ac = UIAlertController(title: title.isEmpty ? nil : title,
                                   message: message,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true) // Show the alert
    }
}

/**
 * EXTENSION: Adds UITextFieldDelegate conformance
 * 
 * WHAT IT DOES: Handles keyboard "Return" key presses
 * - When user taps Return, moves focus to next field
 * - On last field, dismisses keyboard
 * 
 * PROTOCOL CONFORMANCE: UITextFieldDelegate defines methods for text field events
 */
extension RegisterViewController: UITextFieldDelegate {
    /**
     * textFieldShouldReturn: Called when user taps Return key on keyboard
     * 
     * PARAMETER: textField - The text field that had Return pressed
     * RETURNS: Bool - true to dismiss keyboard, false to keep it
     * 
     * SWITCH STATEMENT: Pattern matching on which field was active
     * - Moves focus to next field in sequence
     * - On last field, dismisses keyboard (resignFirstResponder)
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            emailField.becomeFirstResponder() // Move to email field
        case emailField:
            passwordField.becomeFirstResponder() // Move to password field
        case passwordField:
            confirmPasswordField.becomeFirstResponder() // Move to confirm field
        default:
            textField.resignFirstResponder() // Dismiss keyboard
        }
        return true // Allow default behavior
    }
}
