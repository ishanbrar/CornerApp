//  MainViewController.swift
import UIKit
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
class MainViewController: UIViewController {

    private var cornerButton: UIButton!
    private var factScrollView: UIScrollView!
    private var commentButton: UIButton!
    private var factLabel: UILabel!
    private var likeButton: UIButton!
    private var dislikeButton: UIButton!
    private var shareButton: UIButton!
    private var profileButton: UIButton!
    private var factHistory: [Fact] = []
    private var undoButton: UIButton!
    private var currentFact: Fact?
    private let firebaseManager = FirebaseManager.shared
    private var commentBadgeLabel: UILabel!
    private var hasCheckedAuth = false
    private var emojiLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRandomFact()
        setupNotificationObserver()
        setupSwipeGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Only check authentication if we're not coming from splash screen
        if !hasCheckedAuth {
            checkAuthenticationStatus()
            hasCheckedAuth = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonStates()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        cornerButton = UIButton(type: .system)
        factScrollView = UIScrollView()
        factLabel = UILabel()
        likeButton = UIButton(type: .system)
        dislikeButton = UIButton(type: .system)
        shareButton = UIButton(type: .system)
        profileButton = UIButton(type: .system)
        undoButton = UIButton(type: .system)
        commentButton = UIButton(type: .system)
        emojiLabel = UILabel()
        commentBadgeLabel = UILabel()

        // Setup scroll view for fact text
        factScrollView.showsVerticalScrollIndicator = true
        factScrollView.showsHorizontalScrollIndicator = false
        factScrollView.backgroundColor = UIColor.clear
        
        emojiLabel.textAlignment = .center
        emojiLabel.font = UIFont.systemFont(ofSize: 36) // Increased from 28 to 36
        emojiLabel.numberOfLines = 1
        emojiLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(emojiLabel)

        // Corner Button with enhanced styling
        cornerButton.setTitle("🎯 Corner", for: .normal)
        cornerButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        cornerButton.backgroundColor = UIColor.systemBlue
        cornerButton.tintColor = .white
        cornerButton.layer.cornerRadius = 28
        cornerButton.layer.shadowColor = UIColor.systemBlue.cgColor
        cornerButton.layer.shadowOpacity = 0.4
        cornerButton.layer.shadowRadius = 8
        cornerButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        cornerButton.addTarget(self, action: #selector(cornerButtonTapped), for: .touchUpInside)

        // Comment Badge
        commentBadgeLabel.backgroundColor = UIColor.systemRed
        commentBadgeLabel.textColor = UIColor.white
        commentBadgeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        commentBadgeLabel.textAlignment = .center
        commentBadgeLabel.layer.cornerRadius = 8
        commentBadgeLabel.layer.masksToBounds = true
        commentBadgeLabel.isHidden = true
        // Fact Label with enhanced styling
        factLabel.numberOfLines = 0
        factLabel.textAlignment = .center
        factLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        factLabel.textColor = UIColor.label
        factLabel.lineBreakMode = .byWordWrapping

        // Buttons
        setupActionButton(likeButton, systemName: "heart", color: .systemRed, action: #selector(likeButtonTapped))
        setupActionButton(dislikeButton, systemName: "heart.slash", color: .systemGray, action: #selector(dislikeButtonTapped))
        setupActionButton(shareButton, systemName: "square.and.arrow.up", color: .systemBlue, action: #selector(shareButtonTapped))
        setupActionButton(profileButton, systemName: "person.circle", color: .systemIndigo, action: #selector(profileButtonTapped))
        setupActionButton(undoButton, systemName: "arrow.uturn.left", color: .systemOrange, action: #selector(undoButtonTapped))
        setupActionButton(commentButton, systemName: "bubble.left.and.bubble.right", color: .systemTeal, action: #selector(openComments))
        

        // Add to view
        [cornerButton, factScrollView, factLabel, likeButton, dislikeButton, shareButton, profileButton, undoButton, commentButton, commentBadgeLabel].forEach {
            view.addSubview($0)
        }
        
        // Add fact label to scroll view
        factScrollView.addSubview(factLabel)

        setupConstraints()
    }

    private func setupActionButton(_ button: UIButton, systemName: String, color: UIColor, action: Selector) {
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = color
        button.backgroundColor = UIColor.systemGray6
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    private func setupConstraints() {
        [cornerButton, factScrollView, factLabel, likeButton, dislikeButton, shareButton, profileButton, undoButton, commentButton, commentBadgeLabel, emojiLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8), // Move up by 12pt (from 20 to 8)
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileButton.widthAnchor.constraint(equalToConstant: 50),
            profileButton.heightAnchor.constraint(equalToConstant: 50),

            // Scroll view for fact text
            factScrollView.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 16), // Move up by 24pt (from 40 to 16)
            factScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            factScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            factScrollView.bottomAnchor.constraint(equalTo: undoButton.topAnchor, constant: -58), // Extend height by 12pt (from -70 to -58)
            
            // Fact label inside scroll view
            factLabel.topAnchor.constraint(equalTo: factScrollView.topAnchor, constant: 16),
            factLabel.leadingAnchor.constraint(equalTo: factScrollView.leadingAnchor, constant: 16),
            factLabel.trailingAnchor.constraint(equalTo: factScrollView.trailingAnchor, constant: -16),
            factLabel.bottomAnchor.constraint(equalTo: factScrollView.bottomAnchor, constant: -16),
            factLabel.widthAnchor.constraint(equalTo: factScrollView.widthAnchor, constant: -32),

            emojiLabel.topAnchor.constraint(equalTo: factScrollView.bottomAnchor, constant: 4), // Move down slightly (from -4 to 4)
            emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emojiLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            undoButton.bottomAnchor.constraint(equalTo: dislikeButton.topAnchor, constant: -20),
            undoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            undoButton.widthAnchor.constraint(equalToConstant: 50),
            undoButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Comment badge
            commentBadgeLabel.topAnchor.constraint(equalTo: commentButton.topAnchor, constant: -5),
            commentBadgeLabel.trailingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 5),
            commentBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            commentBadgeLabel.heightAnchor.constraint(equalToConstant: 16),
            
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

            
            commentButton.widthAnchor.constraint(equalToConstant: 50),
            commentButton.heightAnchor.constraint(equalToConstant: 50),
            commentButton.bottomAnchor.constraint(equalTo: cornerButton.topAnchor, constant: -90),
            commentButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -30),
            commentButton.widthAnchor.constraint(equalToConstant: 50),
            commentButton.heightAnchor.constraint(equalToConstant: 50),

            undoButton.bottomAnchor.constraint(equalTo: cornerButton.topAnchor, constant: -90),
            undoButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 30),
            undoButton.widthAnchor.constraint(equalToConstant: 50),
            undoButton.heightAnchor.constraint(equalToConstant: 50),


            cornerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            cornerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cornerButton.widthAnchor.constraint(equalToConstant: 140),
            cornerButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    private func checkAuthenticationStatus() {
        if firebaseManager.currentUser == nil {
            presentAuthenticationViewController()
        }
    }

    private func presentAuthenticationViewController() {
        let authVC = AuthenticationViewController()
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }

    private func loadRandomFact() {
        if let current = currentFact {
            factHistory.append(current)
        }

        currentFact = firebaseManager.getRandomFact()
        factLabel.text = currentFact?.text ?? "Tap Corner to get a fact!"
        emojiLabel.text = currentFact?.emojis?.joined(separator: " ") ?? ""
        updateButtonStates()
        updateCommentCount()
    }

    private func updateButtonStates() {
        guard let fact = currentFact, let profile = firebaseManager.userProfile else { return }
        
        // Like button: filled red when liked, gray outline when not liked
        if profile.likedFacts.contains(fact.id) {
            likeButton.tintColor = .systemRed
            likeButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
        } else {
            likeButton.tintColor = .systemGray
            likeButton.backgroundColor = UIColor.systemGray6
        }
        
        // Dislike button: filled red when disliked, gray outline when not disliked
        if profile.dislikedFacts.contains(fact.id) {
            dislikeButton.tintColor = .systemRed
            dislikeButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
        } else {
            dislikeButton.tintColor = .systemGray
            dislikeButton.backgroundColor = UIColor.systemGray6
        }
    }
    private func updateCommentCount() {
        guard let fact = currentFact else { return }
        
        let db = Firestore.firestore()
        db.collection("comments")
            .document(fact.id)
            .collection("userComments")
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let documents = snapshot?.documents {
                        let count = documents.count
                        if count > 0 {
                            self?.commentBadgeLabel.text = count > 99 ? "99+" : "\(count)"
                            self?.commentBadgeLabel.isHidden = false
                        } else {
                            self?.commentBadgeLabel.isHidden = true
                        }
                    } else {
                        self?.commentBadgeLabel.isHidden = true
                    }
                }
            }
    }
    

    // MARK: - Actions
    @objc private func cornerButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        firebaseManager.incrementCornerTaps()
        loadRandomFact()
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform.identity
            }
        }
    }
    

    @objc private func openComments(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Check if user is signed in
        guard firebaseManager.currentUser != nil else {
            showAuthenticationRequiredAlert()
            return
        }
        
        guard let fact = currentFact else { 
            print("❌ Error: No current fact available")
            return 
        }
        
        print("📱 Opening comments for factID: \(fact.id)")
        print("📱 Fact text: \(fact.text)")
        
        let vc = CommentViewController()
        vc.factID = fact.id
        vc.factText = fact.text
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func likeButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Check if user is signed in
        guard firebaseManager.currentUser != nil else {
            showAuthenticationRequiredAlert()
            return
        }
        
        guard let fact = currentFact else { return }
        firebaseManager.likeFact(fact.id) {
            DispatchQueue.main.async { self.updateButtonStates() }
        }
    }

    @objc private func dislikeButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Check if user is signed in
        guard firebaseManager.currentUser != nil else {
            showAuthenticationRequiredAlert()
            return
        }
        
        guard let fact = currentFact else { return }
        firebaseManager.dislikeFact(fact.id) {
            DispatchQueue.main.async { self.updateButtonStates() }
        }
    }

    @objc private func undoButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        guard let previousFact = factHistory.popLast() else { return }
        currentFact = previousFact
        factLabel.text = currentFact?.text
        emojiLabel.text = currentFact?.emojis?.joined(separator: " ") ?? ""
        updateButtonStates()
        updateCommentCount()
    }

    @objc private func shareButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        guard let fact = currentFact else { return }
        let activityVC = UIActivityViewController(activityItems: [fact.text], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        present(activityVC, animated: true)
    }

    @objc private func profileButtonTapped(_ sender: UIButton) {
        let profileVC = ProfileViewController()
        profileVC.delegate = self
        let navController = UINavigationController(rootViewController: profileVC)
        present(navController, animated: true)
    }
    
    // MARK: - Authentication Helper
    private func showAuthenticationRequiredAlert() {
        let alert = UIAlertController(
            title: "Sign In Required",
            message: "You need to sign in to like, dislike, or comment on facts.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign In", style: .default) { [weak self] _ in
            // Open profile page for sign in
            let profileVC = ProfileViewController()
            profileVC.delegate = self
            let navController = UINavigationController(rootViewController: profileVC)
            self?.present(navController, animated: true)
        })
        
        present(alert, animated: true)
    }


    // MARK: - Swipe Gesture
    private func setupSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToProfile))
        swipeGesture.direction = .left
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func handleSwipeToProfile() {
        // Same functionality as profile button tap
        let profileVC = ProfileViewController()
        profileVC.delegate = self
        let navController = UINavigationController(rootViewController: profileVC)
        present(navController, animated: true)
    }
    
    // MARK: - Notification Observer
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShowSelectedFact),
            name: NSNotification.Name("ShowSelectedFact"),
            object: nil
        )
    }
    
    @objc private func handleShowSelectedFact(_ notification: Notification) {
        guard let fact = notification.object as? Fact else { return }
        
        // Set the selected fact as current
        currentFact = fact
        factLabel.text = fact.text
        emojiLabel.text = fact.emojis?.joined(separator: " ") ?? ""
        updateButtonStates()
        updateCommentCount()
        
        print("📱 Showing selected fact from liked/disliked page: \(fact.id)")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension MainViewController: ProfileViewControllerDelegate {
    func didSelectFact(_ fact: Fact) {
        currentFact = fact
        factLabel.text = fact.text
        emojiLabel.text = fact.emojis?.joined(separator: " ") ?? ""
        updateButtonStates()
        updateCommentCount()
    }
    func didSearchForEmoji(_ emoji: String) {  // ← NEW
            // This method is called when a user searches for an emoji in the profile
            // The fact selection is already handled by didSelectFact
            // We can add additional logging or analytics here if needed
            print("🔍 User searched for emoji: \(emoji)")
        }
}

