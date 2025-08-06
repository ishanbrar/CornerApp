import UIKit
import FirebaseFirestore

class StatsViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mostLikedCommentView = UIView()
    private let mostLikedCommentLabel = UILabel()
    private let mostLikedCommentText = UILabel()
    private let mostLikedCommentLikes = UILabel()
    private let topFactPackView = UIView()
    private let topFactPackLabel = UILabel()
    private let topFactPackName = UILabel()
    private let topFactPackLikes = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private let firebaseManager = FirebaseManager.shared
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Stats"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup most liked comment view
        setupMostLikedCommentView()
        
        // Setup top fact pack view
        setupTopFactPackView()
        
        // Setup loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = UIColor.systemBlue
        view.addSubview(loadingIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Most liked comment view constraints
            mostLikedCommentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mostLikedCommentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mostLikedCommentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mostLikedCommentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            // Top fact pack view constraints
            topFactPackView.topAnchor.constraint(equalTo: mostLikedCommentView.bottomAnchor, constant: 20),
            topFactPackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topFactPackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            topFactPackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            topFactPackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupMostLikedCommentView() {
        mostLikedCommentView.backgroundColor = UIColor.systemBackground
        mostLikedCommentView.layer.cornerRadius = 12
        mostLikedCommentView.layer.borderWidth = 1
        mostLikedCommentView.layer.borderColor = UIColor.systemGray4.cgColor
        mostLikedCommentView.layer.shadowColor = UIColor.black.cgColor
        mostLikedCommentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mostLikedCommentView.layer.shadowRadius = 4
        mostLikedCommentView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.1
        mostLikedCommentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add tap gesture for opening the associated fact
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mostLikedCommentTapped))
        mostLikedCommentView.addGestureRecognizer(tapGesture)
        mostLikedCommentView.isUserInteractionEnabled = true
        
        // Setup labels
        mostLikedCommentLabel.text = "🔥 Most Liked Comment"
        mostLikedCommentLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        mostLikedCommentLabel.textColor = UIColor.label
        
        mostLikedCommentText.text = "Loading..."
        mostLikedCommentText.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        mostLikedCommentText.textColor = UIColor.secondaryLabel
        mostLikedCommentText.numberOfLines = 3
        
        mostLikedCommentLikes.text = "0 likes"
        mostLikedCommentLikes.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        mostLikedCommentLikes.textColor = UIColor.systemRed
        
        // Add to view hierarchy
        contentView.addSubview(mostLikedCommentView)
        mostLikedCommentView.addSubview(mostLikedCommentLabel)
        mostLikedCommentView.addSubview(mostLikedCommentText)
        mostLikedCommentView.addSubview(mostLikedCommentLikes)
        
        mostLikedCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        mostLikedCommentText.translatesAutoresizingMaskIntoConstraints = false
        mostLikedCommentLikes.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mostLikedCommentLabel.topAnchor.constraint(equalTo: mostLikedCommentView.topAnchor, constant: 16),
            mostLikedCommentLabel.leadingAnchor.constraint(equalTo: mostLikedCommentView.leadingAnchor, constant: 16),
            mostLikedCommentLabel.trailingAnchor.constraint(equalTo: mostLikedCommentView.trailingAnchor, constant: -16),
            
            mostLikedCommentText.topAnchor.constraint(equalTo: mostLikedCommentLabel.bottomAnchor, constant: 8),
            mostLikedCommentText.leadingAnchor.constraint(equalTo: mostLikedCommentView.leadingAnchor, constant: 16),
            mostLikedCommentText.trailingAnchor.constraint(equalTo: mostLikedCommentView.trailingAnchor, constant: -16),
            
            mostLikedCommentLikes.topAnchor.constraint(equalTo: mostLikedCommentText.bottomAnchor, constant: 8),
            mostLikedCommentLikes.leadingAnchor.constraint(equalTo: mostLikedCommentView.leadingAnchor, constant: 16),
            mostLikedCommentLikes.bottomAnchor.constraint(equalTo: mostLikedCommentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTopFactPackView() {
        topFactPackView.backgroundColor = UIColor.systemBackground
        topFactPackView.layer.cornerRadius = 12
        topFactPackView.layer.borderWidth = 1
        topFactPackView.layer.borderColor = UIColor.systemGray4.cgColor
        topFactPackView.layer.shadowColor = UIColor.black.cgColor
        topFactPackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        topFactPackView.layer.shadowRadius = 4
        topFactPackView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.1
        topFactPackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup labels
        topFactPackLabel.text = "📊 Top Fact Pack"
        topFactPackLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        topFactPackLabel.textColor = UIColor.label
        
        topFactPackName.text = "Loading..."
        topFactPackName.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        topFactPackName.textColor = UIColor.systemBlue
        
        topFactPackLikes.text = "0 total likes"
        topFactPackLikes.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        topFactPackLikes.textColor = UIColor.secondaryLabel
        
        // Add to view hierarchy
        contentView.addSubview(topFactPackView)
        topFactPackView.addSubview(topFactPackLabel)
        topFactPackView.addSubview(topFactPackName)
        topFactPackView.addSubview(topFactPackLikes)
        
        topFactPackLabel.translatesAutoresizingMaskIntoConstraints = false
        topFactPackName.translatesAutoresizingMaskIntoConstraints = false
        topFactPackLikes.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topFactPackLabel.topAnchor.constraint(equalTo: topFactPackView.topAnchor, constant: 16),
            topFactPackLabel.leadingAnchor.constraint(equalTo: topFactPackView.leadingAnchor, constant: 16),
            topFactPackLabel.trailingAnchor.constraint(equalTo: topFactPackView.trailingAnchor, constant: -16),
            
            topFactPackName.topAnchor.constraint(equalTo: topFactPackLabel.bottomAnchor, constant: 8),
            topFactPackName.leadingAnchor.constraint(equalTo: topFactPackView.leadingAnchor, constant: 16),
            topFactPackName.trailingAnchor.constraint(equalTo: topFactPackView.trailingAnchor, constant: -16),
            
            topFactPackLikes.topAnchor.constraint(equalTo: topFactPackName.bottomAnchor, constant: 8),
            topFactPackLikes.leadingAnchor.constraint(equalTo: topFactPackView.leadingAnchor, constant: 16),
            topFactPackLikes.bottomAnchor.constraint(equalTo: topFactPackView.bottomAnchor, constant: -16)
        ])
    }
    
    private func loadStats() {
        loadingIndicator.startAnimating()
        
        // Load most liked comment
        loadMostLikedComment()
        
        // Load top fact pack
        loadTopFactPack()
    }
    
    private func loadMostLikedComment() {
        guard let user = firebaseManager.currentUser else {
            mostLikedCommentText.text = "No user signed in"
            return
        }
        
        print("🔍 Loading most liked comment for user: \(user.email ?? "unknown")")
        
        // Get all comments by the current user
        db.collection("comments").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error loading comments: \(error)")
                    self.mostLikedCommentText.text = "Error loading comments"
                    return
                }
                
                var userComments: [(comment: Comment, factID: String, likes: Int)] = []
                let group = DispatchGroup()
                
                // Process all fact documents
                for factDoc in snapshot?.documents ?? [] {
                    let factID = factDoc.documentID
                    group.enter()
                    
                    // Get user comments for this fact
                    self.db.collection("comments").document(factID)
                        .collection("userComments")
                        .whereField("username", isEqualTo: user.email ?? "")
                        .getDocuments { commentSnapshot, commentError in
                            
                            defer { group.leave() }
                            
                            if let commentError = commentError {
                                print("❌ Error loading user comments for fact \(factID): \(commentError)")
                                return
                            }
                            
                            for commentDoc in commentSnapshot?.documents ?? [] {
                                if let commentData = commentDoc.data() as? [String: Any],
                                   let commentText = commentData["commentText"] as? String,
                                   let timestamp = commentData["timestamp"] as? Timestamp {
                                    
                                    // Get like count for this comment
                                    let likeCount = commentData["likeCount"] as? Int ?? 0
                                    
                                    let comment = Comment(
                                        username: user.email ?? "",
                                        commentText: commentText,
                                        timestamp: timestamp.dateValue(),
                                        likeCount: likeCount,
                                        likedByCurrentUser: false
                                    )
                                    
                                    userComments.append((comment: comment, factID: factID, likes: likeCount))
                                    print("📝 Found comment: '\(commentText)' with \(likeCount) likes")
                                }
                            }
                        }
                }
                
                // When all comments are loaded, find the most liked one
                group.notify(queue: .main) {
                    print("📊 Total user comments found: \(userComments.count)")
                    
                    if userComments.isEmpty {
                        self.mostLikedCommentText.text = "No comments found"
                        self.mostLikedCommentLikes.text = "0 likes"
                        return
                    }
                    
                    // Find the most liked comment (or first one if tied)
                    let mostLiked = userComments.max { first, second in
                        if first.likes == second.likes {
                            // If tied, prefer the first one (earlier in array)
                            return false
                        }
                        return first.likes < second.likes
                    }
                    
                    if let mostLiked = mostLiked {
                        print("🏆 Most liked comment: '\(mostLiked.comment.commentText)' with \(mostLiked.likes) likes")
                        self.updateMostLikedComment(mostLiked.comment, factID: mostLiked.factID, likes: mostLiked.likes)
                    } else {
                        self.mostLikedCommentText.text = "No comments found"
                        self.mostLikedCommentLikes.text = "0 likes"
                    }
                }
            }
        }
    }
    
    private func loadTopFactPack() {
        guard let user = firebaseManager.currentUser else {
            topFactPackName.text = "No user signed in"
            return
        }
        
        // Load all facts and count likes by fact pack
        firebaseManager.loadAllFactsForProfile { [weak self] allFacts in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                var factPackLikes: [String: Int] = [:]
                
                for fact in allFacts {
                    let factPack = fact.factPack ?? "Unknown"
                    if self.firebaseManager.isFactLiked(fact.id) {
                        factPackLikes[factPack, default: 0] += 1
                    }
                }
                
                // Find the fact pack with most likes
                if let topPack = factPackLikes.max(by: { $0.value < $1.value }) {
                    let factPackManager = FactPackManager.shared
                    let packInfo = factPackManager.getFactPackInfo(topPack.key)
                    self.updateTopFactPack(packInfo.name, likes: topPack.value)
                } else {
                    self.topFactPackName.text = "No liked facts found"
                    self.topFactPackLikes.text = "0 total likes"
                }
                
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    private func updateMostLikedComment(_ comment: Comment, factID: String, likes: Int) {
        mostLikedCommentText.text = comment.commentText
        mostLikedCommentLikes.text = "\(likes) likes"
        
        // Store factID for tap handling
        mostLikedCommentView.tag = factID.hashValue
        objc_setAssociatedObject(mostLikedCommentView, "factID", factID, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func updateTopFactPack(_ packName: String, likes: Int) {
        topFactPackName.text = packName
        topFactPackLikes.text = "\(likes) total likes"
    }
    
    @objc private func mostLikedCommentTapped() {
        guard let factID = objc_getAssociatedObject(mostLikedCommentView, "factID") as? String else {
            return
        }
        
        // Find the fact and navigate to it
        firebaseManager.loadAllFactsForProfile { [weak self] allFacts in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let fact = allFacts.first(where: { $0.id == factID }) {
                    // Navigate back to main view and show the fact
                    self.navigationController?.popViewController(animated: true)
                    
                    // Post notification to show the selected fact
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ShowSelectedFact"),
                        object: fact
                    )
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update shadow opacity for dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            mostLikedCommentView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.1
            topFactPackView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.1
        }
    }
} 