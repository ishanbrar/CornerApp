import UIKit

class AuthenticationViewController: UIViewController {
    
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!
    private var signInButton: UIButton!
    private var signUpButton: UIButton!
    private var titleLabel: UILabel!
    private var usernameTextField: UITextField!
    private var logoImageView: UIImageView!
    private var containerView: UIView!

    private var activityIndicator: UIActivityIndicatorView!
    private var isSignUpMode = false

    
    private let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient layer frame when view layout changes
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    private func setupUI() {
        // Set up the background with a subtle gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Initialize UI elements
        containerView = UIView()
        titleLabel = UILabel()
        emailTextField = UITextField()
        passwordTextField = UITextField()
        usernameTextField = UITextField()
        logoImageView = UIImageView()
        signInButton = UIButton(type: .system)
        signUpButton = UIButton(type: .system)
        activityIndicator = UIActivityIndicatorView(style: .medium)
        
        // Logo Image
        logoImageView.image = UIImage(named: "CornerLogo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .white
        
        // Title Label
        titleLabel.text = "Corner"
        titleLabel.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        

        
        // Container View for form elements
        containerView.backgroundColor = UIColor(white: 0.05, alpha: 0.8)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(white: 0.2, alpha: 1.0).cgColor
        
        // Email TextField
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        emailTextField.font = UIFont.systemFont(ofSize: 16)
        emailTextField.textColor = .white
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0)]
        )
        emailTextField.layer.cornerRadius = 12
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor(white: 0.2, alpha: 1.0).cgColor
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        emailTextField.leftViewMode = .always
        emailTextField.delegate = self
        
        // Username TextField
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .none
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        usernameTextField.font = UIFont.systemFont(ofSize: 16)
        usernameTextField.textColor = .white
        usernameTextField.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0)]
        )
        usernameTextField.layer.cornerRadius = 12
        usernameTextField.layer.borderWidth = 1
        usernameTextField.layer.borderColor = UIColor(white: 0.2, alpha: 1.0).cgColor
        usernameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        usernameTextField.leftViewMode = .always
        usernameTextField.delegate = self
        usernameTextField.isHidden = true // Hidden by default for sign in
             
        // Password TextField
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        passwordTextField.font = UIFont.systemFont(ofSize: 16)
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 0.5, alpha: 1.0)]
        )
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor(white: 0.2, alpha: 1.0).cgColor
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.delegate = self
        
        // Sign In Button
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.backgroundColor = .white
        signInButton.setTitleColor(.black, for: .normal)
        signInButton.layer.cornerRadius = 12
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        // Add shadow to button
        signInButton.layer.shadowColor = UIColor.black.cgColor
        signInButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        signInButton.layer.shadowRadius = 8
        signInButton.layer.shadowOpacity = 0.3
        
        // Sign Up Button
        signUpButton.setTitle("Create Account", for: .normal)
        signUpButton.backgroundColor = .clear
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 12
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.white.cgColor
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        // Activity Indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        
        // Add to view
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(containerView)
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(usernameTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(activityIndicator)

        
        setupConstraints()
    }
    
    private func setupConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Logo Image
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            
            // Container View
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 250),
            
            // Email TextField
            emailTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Username TextField
            usernameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            usernameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Sign In Button
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 60),
            signInButton.widthAnchor.constraint(equalToConstant: 320),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Sign Up Button
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20),
            signUpButton.widthAnchor.constraint(equalToConstant: 320),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
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
                    
                    // Play success sound and haptic feedback
                    SoundManager.shared.playSuccessSound()
                    SoundManager.shared.playSuccessHaptic()
                    
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
           
           // Update button styling for sign up mode
           signInButton.backgroundColor = .clear
           signInButton.setTitleColor(.white, for: .normal)
           signInButton.layer.borderWidth = 1
           signInButton.layer.borderColor = UIColor.white.cgColor
           signInButton.layer.shadowOpacity = 0
           
           signUpButton.backgroundColor = .white
           signUpButton.setTitleColor(.black, for: .normal)
           signUpButton.layer.borderWidth = 0
           signUpButton.layer.shadowColor = UIColor.black.cgColor
           signUpButton.layer.shadowOffset = CGSize(width: 0, height: 4)
           signUpButton.layer.shadowRadius = 8
           signUpButton.layer.shadowOpacity = 0.3
           
           // Update constraints for username field
           UIView.animate(withDuration: 0.3) {
               self.view.layoutIfNeeded()
           }
       }
       
       private func switchToSignInMode() {
           isSignUpMode = false
           usernameTextField.isHidden = true
           signInButton.setTitle("Sign In", for: .normal)
           signUpButton.setTitle("Create Account", for: .normal)
           
           // Update button styling for sign in mode
           signInButton.backgroundColor = .white
           signInButton.setTitleColor(.black, for: .normal)
           signInButton.layer.borderWidth = 0
           signInButton.layer.shadowColor = UIColor.black.cgColor
           signInButton.layer.shadowOffset = CGSize(width: 0, height: 4)
           signInButton.layer.shadowRadius = 8
           signInButton.layer.shadowOpacity = 0.3
           
           signUpButton.backgroundColor = .clear
           signUpButton.setTitleColor(.white, for: .normal)
           signUpButton.layer.borderWidth = 1
           signUpButton.layer.borderColor = UIColor.white.cgColor
           signUpButton.layer.shadowOpacity = 0
           
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Add focus effect
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor.white.cgColor
            textField.layer.borderWidth = 2
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Remove focus effect
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor(white: 0.2, alpha: 1.0).cgColor
            textField.layer.borderWidth = 1
        }
    }
}
