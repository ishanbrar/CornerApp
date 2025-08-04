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
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Setup fact card view
        factCardView.backgroundColor = UIColor.systemBackground
        factCardView.layer.cornerRadius = 16
        factCardView.layer.shadowColor = UIColor.black.cgColor
        factCardView.layer.shadowOpacity = 0.1
        factCardView.layer.shadowRadius = 8
        factCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Setup fact label
        factLabel.text = factText
        factLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        factLabel.numberOfLines = 0
        factLabel.textColor = UIColor.label
        factLabel.lineBreakMode = .byWordWrapping
        
        // Setup comment count label
        commentCountLabel.text = "0 comments"
        commentCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        commentCountLabel.textColor = UIColor.secondaryLabel
        
        // Setup table view
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        // Setup comment field container
        let commentContainerView = UIView()
        commentContainerView.backgroundColor = UIColor.systemBackground
        commentContainerView.layer.cornerRadius = 12
        commentContainerView.layer.shadowColor = UIColor.black.cgColor
        commentContainerView.layer.shadowOpacity = 0.08
        commentContainerView.layer.shadowRadius = 6
        commentContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Setup comment field
        commentField.placeholder = "Add your comment..."
        commentField.font = UIFont.systemFont(ofSize: 16)
        commentField.backgroundColor = UIColor.clear
        commentField.borderStyle = .none
        commentField.delegate = self
        
        // Setup send button
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        sendButton.backgroundColor = UIColor.systemBlue
        sendButton.tintColor = UIColor.white
        sendButton.layer.cornerRadius = 8
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
                    self?.comments = documents.compactMap {
                        try? $0.data(as: Comment.self)
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.updateCommentCount()
                    }
                } else if let error = error {
                    print("❌ Error fetching comments: \(error)")
                }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
