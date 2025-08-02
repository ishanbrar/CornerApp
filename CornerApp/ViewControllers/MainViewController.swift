import UIKit

class MainViewController: UIViewController {
    
    private var cornerButton: UIButton!
    private var factLabel: UILabel!
    private var likeButton: UIButton!
    private var dislikeButton: UIButton!
    private var shareButton: UIButton!
    private var profileButton: UIButton!
    
    private var currentFact: Fact?
    private let firebaseManager = FirebaseManager.shared
    private var hasCheckedAuth = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRandomFact()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Check auth status after view appears in window hierarchy
        checkAuthenticationStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonStates()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Initialize UI elements
        cornerButton = UIButton(type: .system)
        factLabel = UILabel()
        likeButton = UIButton(type: .system)
        dislikeButton = UIButton(type: .system)
        shareButton = UIButton(type: .system)
        profileButton = UIButton(type: .system)
        
        // Corner Button
        cornerButton.setTitle("Corner", for: .normal)
        cornerButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        cornerButton.backgroundColor = UIColor.systemBlue
        cornerButton.tintColor = .white
        cornerButton.layer.cornerRadius = 25
        cornerButton.layer.shadowColor = UIColor.black.cgColor
        cornerButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        cornerButton.layer.shadowRadius = 4
        cornerButton.layer.shadowOpacity = 0.1
        cornerButton.addTarget(self, action: #selector(cornerButtonTapped), for: .touchUpInside)
        
        // Fact Label
        factLabel.numberOfLines = 0
        factLabel.textAlignment = .center
        factLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        factLabel.textColor = UIColor.label
        factLabel.text = "Tap Corner to get a fact!"
        
        // Action Buttons
        setupActionButton(likeButton, systemName: "heart", color: .systemRed, action: #selector(likeButtonTapped))
        setupActionButton(dislikeButton, systemName: "heart.slash", color: .systemGray, action: #selector(dislikeButtonTapped))
        setupActionButton(shareButton, systemName: "square.and.arrow.up", color: .systemBlue, action: #selector(shareButtonTapped))
        setupActionButton(profileButton, systemName: "person.circle", color: .systemIndigo, action: #selector(profileButtonTapped))
        
        // Add to view
        view.addSubview(cornerButton)
        view.addSubview(factLabel)
        view.addSubview(likeButton)
        view.addSubview(dislikeButton)
        view.addSubview(shareButton)
        view.addSubview(profileButton)
        
        // Layout
        setupConstraints()
    }
    
    private func setupActionButton(_ button: UIButton, systemName: String, color: UIColor, action: Selector) {
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = color
        button.backgroundColor = UIColor.systemGray6
        button.layer.cornerRadius = 25
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
    private func setupConstraints() {
        cornerButton.translatesAutoresizingMaskIntoConstraints = false
        factLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        dislikeButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Profile Button (top right)
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileButton.widthAnchor.constraint(equalToConstant: 50),
            profileButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Fact Label (centered)
            factLabel.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 40),
            factLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            factLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            // Action Buttons above Corner Button
            dislikeButton.bottomAnchor.constraint(equalTo: cornerButton.topAnchor, constant: -20),
            dislikeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dislikeButton.widthAnchor.constraint(equalToConstant: 50),
            dislikeButton.heightAnchor.constraint(equalToConstant: 50),
            
            likeButton.centerYAnchor.constraint(equalTo: dislikeButton.centerYAnchor),
            likeButton.trailingAnchor.constraint(equalTo: dislikeButton.leadingAnchor, constant: -40),
            likeButton.widthAnchor.constraint(equalToConstant: 50),
            likeButton.heightAnchor.constraint(equalToConstant: 50),
            
            shareButton.centerYAnchor.constraint(equalTo: dislikeButton.centerYAnchor),
            shareButton.leadingAnchor.constraint(equalTo: dislikeButton.trailingAnchor, constant: 40),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Corner Button at bottom center
            cornerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            cornerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cornerButton.widthAnchor.constraint(equalToConstant: 140),
            cornerButton.heightAnchor.constraint(equalToConstant: 55)
        ])

    }
    
    private func checkAuthenticationStatus() {
        print("🔥 Checking auth status...")
        print("🔥 Current user: \(firebaseManager.currentUser?.email ?? "nil")")
        
        if firebaseManager.currentUser == nil {
            print("🔥 No user found - presenting auth screen")
            presentAuthenticationViewController()
        } else {
            print("🔥 User already logged in: \(firebaseManager.currentUser?.email ?? "")")
        }
    }
    
    private func presentAuthenticationViewController() {
        let authVC = AuthenticationViewController()
        authVC.modalPresentationStyle = .fullScreen
        
        print("🔥 About to present auth view controller")
        present(authVC, animated: true) {
            print("🔥 Auth view controller presented successfully")
        }
    }
    
    private func loadRandomFact() {
        currentFact = firebaseManager.getRandomFact()
        factLabel.text = currentFact?.text ?? "Tap Corner to get a fact!"
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        guard let fact = currentFact, let profile = firebaseManager.userProfile else { return }
        
        likeButton.tintColor = profile.likedFacts.contains(fact.id) ? .systemRed : .systemGray
        dislikeButton.tintColor = profile.dislikedFacts.contains(fact.id) ? .systemGray : .systemGray2
    }
    
    // MARK: - Actions
    @objc private func cornerButtonTapped(_ sender: UIButton) {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        firebaseManager.incrementCornerTaps()
        loadRandomFact()
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform.identity
            }
        }
    }

    
    @objc private func likeButtonTapped(_ sender: UIButton) {
        guard let fact = currentFact else { return }
        firebaseManager.likeFact(fact.id)
        updateButtonStates()
    }
    
    @objc private func dislikeButtonTapped(_ sender: UIButton) {
        guard let fact = currentFact else { return }
        firebaseManager.dislikeFact(fact.id)
        updateButtonStates()
    }
    
    @objc private func shareButtonTapped(_ sender: UIButton) {
        guard let fact = currentFact else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [fact.text],
            applicationActivities: nil
        )
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        present(activityViewController, animated: true)
    }
    
    @objc private func profileButtonTapped(_ sender: UIButton) {
        let profileVC = ProfileViewController()
        let navController = UINavigationController(rootViewController: profileVC)
        present(navController, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
