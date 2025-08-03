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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchComments()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let factLabel = UILabel()
        factLabel.text = factText
        factLabel.font = .boldSystemFont(ofSize: 18)
        factLabel.numberOfLines = 0
        
        view.addSubview(factLabel)
        view.addSubview(tableView)
        view.addSubview(commentField)
        view.addSubview(sendButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        commentField.placeholder = "Add a comment..."
        commentField.borderStyle = .roundedRect
        commentField.delegate = self

        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        
        // Layout
        factLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        commentField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            factLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            factLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            factLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: factLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: commentField.topAnchor, constant: -10),
            
            commentField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            commentField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            commentField.heightAnchor.constraint(equalToConstant: 44),
            
            sendButton.leadingAnchor.constraint(equalTo: commentField.trailingAnchor, constant: 10),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: commentField.centerYAnchor)
        ])
    }

    @objc private func sendComment() {
        guard let text = commentField.text, !text.isEmpty,
              let user = Auth.auth().currentUser else { return }

        let commentID = UUID().uuidString
        let comment = Comment(
            username: user.email ?? "Anonymous",
            commentText: text,
            timestamp: Date(),
            likeCount: 0,
            likedByCurrentUser: false
        )

        do {
            try db.collection("comments")
                .document(factID)
                .collection("userComments")
                .document(commentID) // Use the UUID here
                .setData(from: comment)
            
            commentField.text = ""
            fetchComments()
        } catch {
            print("❌ Error posting comment: \(error)")
        }
    }


    private func fetchComments() {
        db.collection("comments")
            .document(factID)
            .collection("userComments")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let documents = snapshot?.documents {
                    self?.comments = documents.compactMap {
                        try? $0.data(as: Comment.self)
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                } else if let error = error {
                    print("❌ Error fetching comments: \(error)")
                }
            }
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment()
        return true
    }

}
