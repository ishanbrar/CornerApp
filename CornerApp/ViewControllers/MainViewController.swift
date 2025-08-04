import UIKit

class MainViewController: UIViewController {

    private var cornerButton: UIButton!
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
    private var hasCheckedAuth = false
    private var emojiLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRandomFact()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthenticationStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonStates()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        cornerButton = UIButton(type: .system)
        factLabel = UILabel()
        likeButton = UIButton(type: .system)
        dislikeButton = UIButton(type: .system)
        shareButton = UIButton(type: .system)
        profileButton = UIButton(type: .system)
        undoButton = UIButton(type: .system)
        commentButton = UIButton(type: .system)
        emojiLabel = UILabel()

        emojiLabel.textAlignment = .center
        emojiLabel.font = UIFont.systemFont(ofSize: 28)
        emojiLabel.numberOfLines = 1
        emojiLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(emojiLabel)

        // Corner Button
        cornerButton.setTitle("Corner", for: .normal)
        cornerButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        cornerButton.backgroundColor = UIColor.systemBlue
        cornerButton.tintColor = .white
        cornerButton.layer.cornerRadius = 25
        cornerButton.addTarget(self, action: #selector(cornerButtonTapped), for: .touchUpInside)

        // Fact Label
        factLabel.numberOfLines = 0
        factLabel.textAlignment = .center
        factLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        factLabel.textColor = UIColor.label

        // Buttons
        setupActionButton(likeButton, systemName: "heart", color: .systemRed, action: #selector(likeButtonTapped))
        setupActionButton(dislikeButton, systemName: "heart.slash", color: .systemGray, action: #selector(dislikeButtonTapped))
        setupActionButton(shareButton, systemName: "square.and.arrow.up", color: .systemBlue, action: #selector(shareButtonTapped))
        setupActionButton(profileButton, systemName: "person.circle", color: .systemIndigo, action: #selector(profileButtonTapped))
        setupActionButton(undoButton, systemName: "arrow.uturn.left", color: .systemOrange, action: #selector(undoButtonTapped))
        setupActionButton(commentButton, systemName: "bubble.left.and.bubble.right", color: .systemTeal, action: #selector(openComments))

        // Add to view
        [cornerButton, factLabel, likeButton, dislikeButton, shareButton, profileButton, undoButton, commentButton].forEach {
            view.addSubview($0)
        }

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
        [cornerButton, factLabel, likeButton, dislikeButton, shareButton, profileButton, undoButton, commentButton, emojiLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileButton.widthAnchor.constraint(equalToConstant: 50),
            profileButton.heightAnchor.constraint(equalToConstant: 50),

            factLabel.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 40),
            factLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            factLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            emojiLabel.topAnchor.constraint(equalTo: factLabel.bottomAnchor, constant: 16),
            emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emojiLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            undoButton.bottomAnchor.constraint(equalTo: dislikeButton.topAnchor, constant: -20),
            undoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            undoButton.widthAnchor.constraint(equalToConstant: 50),
            undoButton.heightAnchor.constraint(equalToConstant: 50),

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
        guard let fact = currentFact else { return }
        let vc = CommentViewController()
        vc.factID = fact.id
        vc.factText = fact.text
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func likeButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        guard let fact = currentFact else { return }
        firebaseManager.likeFact(fact.id) {
            DispatchQueue.main.async { self.updateButtonStates() }
        }
    }

    @objc private func dislikeButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
    }
    func didSearchForEmoji(_ emoji: String) {  // ← NEW
            // This method is called when a user searches for an emoji in the profile
            // The fact selection is already handled by didSelectFact
            // We can add additional logging or analytics here if needed
            print("🔍 User searched for emoji: \(emoji)")
        }
}

