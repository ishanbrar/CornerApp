import UIKit
import FirebaseFirestore
import FirebaseAuth

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var factID: String!
    var factText: String!
    
    private var comments: [Comment] = []
    private let db = Firestore.firestore()

    private let tableView = UITableView()
    private let commentField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let factCardView = UIView()
    private let factLabel = UILabel()
    private let commentCountLabel = UILabel()
    
    // Add constraints for keyboard handling
    private var commentFieldBottomConstraint: NSLayoutConstraint!
    private var sendButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Validate factID is set
        guard !factID.isEmpty else {
            print("❌ Error: factID not set in CommentViewController")
            navigationController?.popViewController(animated: true)
            return
        }
        
        print("📱 CommentViewController loaded with factID: \(factID)")
        
        setupUI()
        setupKeyboardHandling()
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Comments"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Setup fact card view with enhanced styling
        factCardView.backgroundColor = UIColor.systemBackground
        factCardView.layer.cornerRadius = 20
        factCardView.layer.shadowColor = UIColor.black.cgColor
        factCardView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.15
        factCardView.layer.shadowRadius = 12
        factCardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        factCardView.layer.borderWidth = 1
        factCardView.layer.borderColor = UIColor.systemGray5.cgColor
        
        // Setup fact label with enhanced typography
        factLabel.text = factText
        factLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        factLabel.numberOfLines = 0
        factLabel.textColor = UIColor.label
        factLabel.lineBreakMode = .byWordWrapping
        factLabel.textAlignment = .left
        
        // Setup comment count label with enhanced styling
        commentCountLabel.text = "💬 0 comments"
        commentCountLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        commentCountLabel.textColor = UIColor.systemBlue
        
        // Setup table view with enhanced styling
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.allowsSelection = false
        
        // Setup comment field container with enhanced styling
        let commentContainerView = UIView()
        commentContainerView.backgroundColor = UIColor.systemBackground
        commentContainerView.layer.cornerRadius = 16
        commentContainerView.layer.shadowColor = UIColor.black.cgColor
        commentContainerView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.2 : 0.1
        commentContainerView.layer.shadowRadius = 8
        commentContainerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        commentContainerView.layer.borderWidth = 1
        commentContainerView.layer.borderColor = UIColor.systemGray5.cgColor
        
        // Setup comment field with enhanced styling
        commentField.placeholder = "Add your comment..."
        commentField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        commentField.backgroundColor = UIColor.clear
        commentField.borderStyle = .none
        commentField.delegate = self
        commentField.returnKeyType = .send
        
        // Setup send button with enhanced styling
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        sendButton.backgroundColor = UIColor.systemBlue
        sendButton.tintColor = UIColor.white
        sendButton.layer.cornerRadius = 10
        sendButton.layer.shadowColor = UIColor.systemBlue.cgColor
        sendButton.layer.shadowOpacity = 0.3
        sendButton.layer.shadowRadius = 4
        sendButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        
        // Add subviews
        view.addSubview(factCardView)
        factCardView.addSubview(factLabel)
        factCardView.addSubview(commentCountLabel)
        view.addSubview(tableView)
        view.addSubview(commentContainerView)
        commentContainerView.addSubview(commentField)
        commentContainerView.addSubview(sendButton)
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        // Layout
        factCardView.translatesAutoresizingMaskIntoConstraints = false
        factLabel.translatesAutoresizingMaskIntoConstraints = false
        commentCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        commentContainerView.translatesAutoresizingMaskIntoConstraints = false
        commentField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Store constraints for keyboard handling
        commentContainerView.translatesAutoresizingMaskIntoConstraints = false
        commentFieldBottomConstraint = commentContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        sendButtonBottomConstraint = sendButton.bottomAnchor.constraint(equalTo: commentContainerView.bottomAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            // Fact card
            factCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            factCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            factCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Fact label
            factLabel.topAnchor.constraint(equalTo: factCardView.topAnchor, constant: 20),
            factLabel.leadingAnchor.constraint(equalTo: factCardView.leadingAnchor, constant: 20),
            factLabel.trailingAnchor.constraint(equalTo: factCardView.trailingAnchor, constant: -20),
            
            // Comment count
            commentCountLabel.topAnchor.constraint(equalTo: factLabel.bottomAnchor, constant: 12),
            commentCountLabel.leadingAnchor.constraint(equalTo: factCardView.leadingAnchor, constant: 20),
            commentCountLabel.bottomAnchor.constraint(equalTo: factCardView.bottomAnchor, constant: -20),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: factCardView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: commentContainerView.topAnchor, constant: -16),
            
            // Comment container
            commentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            commentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            commentContainerView.heightAnchor.constraint(equalToConstant: 56),
            commentFieldBottomConstraint,
            
            // Comment field
            commentField.leadingAnchor.constraint(equalTo: commentContainerView.leadingAnchor, constant: 16),
            commentField.topAnchor.constraint(equalTo: commentContainerView.topAnchor, constant: 8),
            commentField.bottomAnchor.constraint(equalTo: commentContainerView.bottomAnchor, constant: -8),
            commentField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            
            // Send button
            sendButton.trailingAnchor.constraint(equalTo: commentContainerView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: commentContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
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
        
        // Update constraints to move text field above keyboard
        commentFieldBottomConstraint.constant = -(keyboardHeight + 20)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // Reset constraints to original position
        commentFieldBottomConstraint.constant = -20
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func sendComment() {
        guard let text = commentField.text, !text.isEmpty,
              let user = Auth.auth().currentUser else { return }

        // Validate factID
        guard !factID.isEmpty else {
            print("❌ Error: factID is empty")
            return
        }
        
        // Check for inappropriate content and play sound if detected
        if containsInappropriateContent(text) {
            SoundManager.shared.playInappropriateContentSound()
        }
        
        print("📝 Posting comment to factID: \(factID)")
        print("📝 Fact text: \(factText ?? "Unknown")")
        
        let commentID = UUID().uuidString
        
        // Get username from user profile
        let username = FirebaseManager.shared.userProfile?.username ?? user.email ?? "Anonymous"
        
        let comment = Comment(
            username: username,
            commentText: text,
            timestamp: Date(),
            likeCount: 0,
            likedByCurrentUser: false
        )

        do {
            try db.collection("comments")
                .document(factID)
                .collection("userComments")
                .document(commentID)
                .setData(from: comment)
            
            print("✅ Comment posted successfully to factID: \(factID)")
            commentField.text = ""
            fetchComments()
        } catch {
            print("❌ Error posting comment: \(error)")
        }
    }

    private func fetchComments() {
        print("🔍 Fetching comments for factID: \(factID)")
        
        db.collection("comments")
            .document(factID)
            .collection("userComments")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let documents = snapshot?.documents {
                    print("📊 Found \(documents.count) comments for factID: \(self?.factID ?? "unknown")")
                    
                    // Load comments and their like status
                    self?.loadCommentsWithLikeStatus(documents: documents) { comments in
                        DispatchQueue.main.async {
                            self?.comments = comments
                            self?.tableView.reloadData()
                            self?.updateCommentCount()
                        }
                    }
                } else if let error = error {
                    print("❌ Error fetching comments: \(error)")
                }
            }
    }
    
    private func loadCommentsWithLikeStatus(documents: [QueryDocumentSnapshot], completion: @escaping ([Comment]) -> Void) {
        let group = DispatchGroup()
        var commentsWithLikes: [Comment] = []
        let currentUserID = Auth.auth().currentUser?.uid
        
        for document in documents {
            group.enter()
            
            do {
                var comment = try document.data(as: Comment.self)
                
                // Check if current user liked this comment
                let likesRef = document.reference.collection("likes")
                let userLikeRef = likesRef.document(currentUserID ?? "")
                
                userLikeRef.getDocument { likeSnapshot, _ in
                    comment.likedByCurrentUser = likeSnapshot?.exists ?? false
                    commentsWithLikes.append(comment)
                    group.leave()
                }
            } catch {
                print("❌ Error decoding comment: \(error)")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Sort comments by timestamp (newest first)
            let sortedComments = commentsWithLikes.sorted { $0.timestamp > $1.timestamp }
            completion(sortedComments)
        }
    }
    
    private func updateCommentCount() {
        let count = comments.count
        commentCountLabel.text = count == 1 ? "1 comment" : "\(count) comments"
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        cell.configure(with: comments[indexPath.row], factID: factID)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment()
        return true
    }
    
    // MARK: - Content Filtering
    private func containsInappropriateContent(_ text: String) -> Bool {
        let lowercaseText = text.lowercased()
        
        // List of inappropriate words/phrases to filter
        let inappropriateWords = [
            "retard", "retarded", "retards",
            // Add other words you want to filter
            // You can expand this list as needed
        ]
        
        for word in inappropriateWords {
            if lowercaseText.contains(word) {
                print("⚠️ Inappropriate content detected: \(word)")
                return true
            }
        }
        
        return false
    }
    

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update shadow opacity for dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            factCardView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.15
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
