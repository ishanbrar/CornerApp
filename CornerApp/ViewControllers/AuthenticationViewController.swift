import UIKit

class AuthenticationViewController: UIViewController {
    
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!
    private var signInButton: UIButton!
    private var signUpButton: UIButton!
    private var titleLabel: UILabel!
    private var usernameTextField: UITextField!

    private var activityIndicator: UIActivityIndicatorView!
    private var isSignUpMode = false

    
    private let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Initialize UI elements
        titleLabel = UILabel()
        emailTextField = UITextField()
        passwordTextField = UITextField()
        usernameTextField = UITextField()

        signInButton = UIButton(type: .system)
        signUpButton = UIButton(type: .system)
        activityIndicator = UIActivityIndicatorView(style: .medium)
        
        // Title Label
        titleLabel.text = "Corner"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.systemBlue
        
        // Email TextField
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.backgroundColor = UIColor.systemGray6
        emailTextField.font = UIFont.systemFont(ofSize: 16)
        emailTextField.delegate = self
        
        // Username TextField
             usernameTextField.placeholder = "Username"
             usernameTextField.borderStyle = .roundedRect
             usernameTextField.autocapitalizationType = .none
             usernameTextField.autocorrectionType = .no
             usernameTextField.backgroundColor = UIColor.systemGray6
             usernameTextField.font = UIFont.systemFont(ofSize: 16)
             usernameTextField.delegate = self
             usernameTextField.isHidden = true // Hidden by default for sign in
             
        // Password TextField
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.backgroundColor = UIColor.systemGray6
        passwordTextField.font = UIFont.systemFont(ofSize: 16)
        passwordTextField.delegate = self
        
        
        
        // Sign In Button
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.backgroundColor = UIColor.systemBlue
        signInButton.tintColor = .white
        signInButton.layer.cornerRadius = 8
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        // Sign Up Button
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.backgroundColor = UIColor.systemGreen
        signUpButton.tintColor = .white
        signUpButton.layer.cornerRadius = 8
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        // Activity Indicator
        activityIndicator.hidesWhenStopped = true
        
        // Add to view
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(activityIndicator)
        view.addSubview(usernameTextField)

        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false

        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            
            // Email TextField
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 80),
            emailTextField.widthAnchor.constraint(equalToConstant: 280),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Username TextField
                      usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                      usernameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
                      usernameTextField.widthAnchor.constraint(equalToConstant: 280),
                      usernameTextField.heightAnchor.constraint(equalToConstant: 44),
                      
            
            // Password TextField
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 280),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Sign In Button
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            signInButton.widthAnchor.constraint(equalToConstant: 280),
            signInButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Sign Up Button
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20),
            signUpButton.widthAnchor.constraint(equalToConstant: 280),
            signUpButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 30),
        ])
    }
    
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Listen for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let keyboardHeight = keyboardSize.height
        let bottomPadding = view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - bottomPadding) / 2)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }
    
    private func setButtonsEnabled(_ enabled: Bool) {
        signInButton.isEnabled = enabled
        signUpButton.isEnabled = enabled
        usernameTextField.isEnabled = enabled
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        
        signInButton.alpha = enabled ? 1.0 : 0.6
        signUpButton.alpha = enabled ? 1.0 : 0.6
        
        if enabled {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    private func validateInput() -> (email: String, password: String, username: String?)? {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showAlert(message: "Please enter your email address")
            return nil
        }
        
        guard email.contains("@") && email.contains(".") else {
            showAlert(message: "Please enter a valid email address")
            return nil
        }
        
        guard let password = passwordTextField.text,
              !password.isEmpty else {
            showAlert(message: "Please enter your password")
            return nil
        }
        
        guard password.count >= 6 else {
            showAlert(message: "Password must be at least 6 characters long")
            return nil
        }
        
        // Username validation only for sign up
        if isSignUpMode {
            guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !username.isEmpty else {
                showAlert(message: "Please enter a username")
                return nil
            }
            
            guard username.count >= 3 else {
                showAlert(message: "Username must be at least 3 characters long")
                return nil
            }
            
            guard username.count <= 20 else {
                showAlert(message: "Username must be 20 characters or less")
                return nil
            }
            
            return (email: email, password: password, username: username)
        }
        
        return (email: email, password: password, username: nil)
        }
    
    // MARK: - Actions
    @objc private func signInButtonTapped(_ sender: UIButton) {
        if isSignUpMode {
             // Switch to sign in mode
             switchToSignInMode()
             return
         }
         
        dismissKeyboard()
        
        guard let credentials = validateInput() else { return }
        
        setButtonsEnabled(false)
        
        firebaseManager.signIn(email: credentials.email, password: credentials.password) { [weak self] result in
            DispatchQueue.main.async {
                self?.setButtonsEnabled(true)
                
                switch result {
                case .success:
                    print("✅ Sign in successful - dismissing auth screen")
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let keyWindow = windowScene.windows.first,
                       let rootVC = keyWindow.rootViewController {
                        rootVC.dismiss(animated: true) {
                            print("✅ Auth screen dismissed to root")
                        }
                    }
                case .failure(let error):
                    print("❌ Sign in failed: \(error.localizedDescription)")
                    self?.showAlert(message: self?.formatErrorMessage(error) ?? "Sign in failed")
                }
            }
        }
    }
    
    @objc private func signUpButtonTapped(_ sender: UIButton) {
        if !isSignUpMode {
            // Switch to sign up mode
            switchToSignUpMode()
            return
        }
        
        dismissKeyboard()
        
        guard let credentials = validateInput() else { return }
        
        setButtonsEnabled(false)
        
        firebaseManager.signUp(email: credentials.email, password: credentials.password, username: credentials.username!) { [weak self] result in
                    DispatchQueue.main.async {
                self?.setButtonsEnabled(true)
                
                switch result {
                case .success:
                    print("✅ Sign up successful - dismissing auth screen")
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let keyWindow = windowScene.windows.first,
                       let rootVC = keyWindow.rootViewController {
                        rootVC.dismiss(animated: true) {
                            print("✅ Auth screen dismissed to root")
                        }
                    }
                case .failure(let error):
                    print("❌ Sign up failed: \(error.localizedDescription)")
                    self?.showAlert(message: self?.formatErrorMessage(error) ?? "Sign up failed")
                }
            }
        }
    }
    private func switchToSignUpMode() {
           isSignUpMode = true
           usernameTextField.isHidden = false
           signInButton.setTitle("Back to Sign In", for: .normal)
           signUpButton.setTitle("Create Account", for: .normal)
           
           // Update constraints for username field
           UIView.animate(withDuration: 0.3) {
               self.view.layoutIfNeeded()
           }
       }
       
       private func switchToSignInMode() {
           isSignUpMode = false
           usernameTextField.isHidden = true
           signInButton.setTitle("Sign In", for: .normal)
           signUpButton.setTitle("Sign Up", for: .normal)
           
           // Update constraints for username field
           UIView.animate(withDuration: 0.3) {
               self.view.layoutIfNeeded()
           }
       }
       
    private func formatErrorMessage(_ error: Error) -> String {
        let errorMessage = error.localizedDescription
        
        // Convert Firebase error codes to user-friendly messages
        if errorMessage.contains("email-already-in-use") {
            return "An account with this email already exists. Please sign in instead."
        } else if errorMessage.contains("invalid-email") {
            return "Please enter a valid email address."
        } else if errorMessage.contains("weak-password") {
            return "Password is too weak. Please choose a stronger password."
        } else if errorMessage.contains("user-not-found") {
            return "No account found with this email. Please sign up first."
        } else if errorMessage.contains("wrong-password") {
            return "Incorrect password. Please try again."
        } else if errorMessage.contains("too-many-requests") {
            return "Too many failed attempts. Please try again later."
        } else if errorMessage.contains("network-request-failed") {
            return "Network error. Please check your internet connection."
        }
        
        return errorMessage
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextField Delegate
extension AuthenticationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            if isSignUpMode {
                       usernameTextField.becomeFirstResponder()
                   } else {
                       passwordTextField.becomeFirstResponder()
                   }
               } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            dismissKeyboard()
            if isSignUpMode {
                           signUpButtonTapped(signUpButton)
                       } else {
                           signInButtonTapped(signInButton)
                       }
        }
        return true
    }
}
