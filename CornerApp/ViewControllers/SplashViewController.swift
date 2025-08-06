import UIKit

class SplashViewController: UIViewController {
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If we're coming back from auth screen, transition to main app
        if presentedViewController == nil && FirebaseManager.shared.currentUser != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.transitionToMainApp()
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Setup logo image
        logoImageView.image = UIImage(named: "CornerLogo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.alpha = 0
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup title label
        titleLabel.text = "SIkho Mode Engineering"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup subtitle label
        subtitleLabel.text = "© 2025"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor.secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup loading indicator
        loadingIndicator.color = UIColor.systemBlue
        loadingIndicator.alpha = 0
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to view
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(loadingIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Logo constraints
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subtitle constraints
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Loading indicator constraints
            loadingIndicator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func startAnimation() {
        // Start loading indicator
        loadingIndicator.startAnimating()
        
        // Animate logo fade in
        UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseInOut) {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            // Scale back to normal
            UIView.animate(withDuration: 0.3) {
                self.logoImageView.transform = CGAffineTransform.identity
            }
        }
        
        // Animate title fade in
        UIView.animate(withDuration: 0.8, delay: 0.6, options: .curveEaseInOut) {
            self.titleLabel.alpha = 1
        }
        
        // Animate subtitle fade in
        UIView.animate(withDuration: 0.8, delay: 0.8, options: .curveEaseInOut) {
            self.subtitleLabel.alpha = 1
        }
        
        // Animate loading indicator fade in
        UIView.animate(withDuration: 0.6, delay: 1.0, options: .curveEaseInOut) {
            self.loadingIndicator.alpha = 1
        }
        
        // Transition to main app after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.transitionToMainApp()
        }
    }
    
    private func transitionToMainApp() {
        // Check authentication status first
        let firebaseManager = FirebaseManager.shared
        
        if firebaseManager.currentUser == nil {
            // User not authenticated - present auth screen
            let authVC = AuthenticationViewController()
            authVC.modalPresentationStyle = .fullScreen
            authVC.modalTransitionStyle = .crossDissolve
            present(authVC, animated: true)
        } else {
            // User authenticated - present main app
            let mainVC = MainViewController()
            let navController = UINavigationController(rootViewController: mainVC)
            navController.modalPresentationStyle = .fullScreen
            navController.modalTransitionStyle = .crossDissolve
            present(navController, animated: true)
        }
    }
} 