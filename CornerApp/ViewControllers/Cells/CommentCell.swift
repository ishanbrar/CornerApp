import UIKit
import FirebaseAuth
import FirebaseFirestore

class CommentCell: UITableViewCell {
    private let containerView = UIView()
    private let usernameLabel = UILabel()
    private let dateLabel = UILabel()
    private let commentLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    private let likeCountLabel = UILabel()

    private var currentComment: Comment?
    private var currentFactID: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with comment: Comment, factID: String) {
        self.currentComment = comment
        self.currentFactID = factID

        usernameLabel.text = comment.username
        dateLabel.text = formatDate(comment.timestamp)
        commentLabel.text = comment.commentText
        likeCountLabel.text = "\(comment.likeCount)"
        
        // Set initial like button state
        let isLiked = comment.likedByCurrentUser ?? false
        likeButton.tintColor = isLiked ? .systemBlue : .gray
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy 'at' h:mm a"
        return formatter.string(from: date)
    }

    private func layoutUI() {
        // Configure cell
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container view for the comment bubble
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        
        [containerView, usernameLabel, dateLabel, commentLabel, likeButton, likeCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(containerView)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(commentLabel)
        containerView.addSubview(likeButton)
        containerView.addSubview(likeCountLabel)

        // Username label - bold and italic
        usernameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        usernameLabel.textColor = UIColor.label
        
        // Date label
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = UIColor.secondaryLabel
        
        // Comment label
        commentLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        commentLabel.textColor = UIColor.label
        commentLabel.numberOfLines = 0
        commentLabel.lineBreakMode = .byWordWrapping
        
        // Like button
        likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        likeButton.tintColor = .gray
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        
        // Like count label
        likeCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        likeCountLabel.textColor = UIColor.secondaryLabel

        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Username label
            usernameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -12),
            
            // Date label
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Comment label
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            commentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            commentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Like button
            likeButton.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 12),
            likeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            likeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Like count label
            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 6),
            likeCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
        ])
    }

    @objc private func likeButtonTapped() {
        guard let comment = currentComment,
              let factID = currentFactID,
              let userID = Auth.auth().currentUser?.uid,
              let commentID = comment.id else {
            print("❌ Missing data")
            return
        }

        let db = Firestore.firestore()
        let commentRef = db.collection("comments")
            .document(factID)
            .collection("userComments")
            .document(commentID)
        
        let likesRef = commentRef.collection("likes")
        let userLikeRef = likesRef.document(userID)

        let isLiked = comment.likedByCurrentUser ?? false

        if isLiked {
            // Unlike: Remove from likes subcollection and decrement count
            userLikeRef.delete { error in
                if let error = error {
                    print("❌ Error unliking comment: \(error)")
                } else {
                    // Update the comment document with new like count
                    commentRef.updateData([
                        "likeCount": FieldValue.increment(Int64(-1))
                    ]) { error in
                        if let error = error {
                            print("❌ Error updating like count: \(error)")
                        } else {
                            print("✅ Comment unliked successfully")
                            // Refresh the comment data
                            self.refreshCommentData()
                        }
                    }
                }
            }
        } else {
            // Like: Add to likes subcollection and increment count
            userLikeRef.setData(["liked": true, "timestamp": FieldValue.serverTimestamp()]) { error in
                if let error = error {
                    print("❌ Error liking comment: \(error)")
                } else {
                    // Update the comment document with new like count
                    commentRef.updateData([
                        "likeCount": FieldValue.increment(Int64(1))
                    ]) { error in
                        if let error = error {
                            print("❌ Error updating like count: \(error)")
                        } else {
                            print("✅ Comment liked successfully")
                            // Refresh the comment data
                            self.refreshCommentData()
                        }
                    }
                }
            }
        }
    }
    
    private func refreshCommentData() {
        guard let comment = currentComment,
              let factID = currentFactID,
              let commentID = comment.id else { return }
        
        let db = Firestore.firestore()
        let commentRef = db.collection("comments")
            .document(factID)
            .collection("userComments")
            .document(commentID)
        
        commentRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error refreshing comment data: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            // Update like count from document
            let newLikeCount = data["likeCount"] as? Int ?? 0
            
            // Check if current user liked this comment
            let userID = Auth.auth().currentUser?.uid
            let likesRef = commentRef.collection("likes")
            let userLikeRef = likesRef.document(userID ?? "")
            
            userLikeRef.getDocument { [weak self] likeSnapshot, _ in
                let isLiked = likeSnapshot?.exists ?? false
                
                DispatchQueue.main.async {
                    self?.likeCountLabel.text = "\(newLikeCount)"
                    self?.likeButton.tintColor = isLiked ? .systemBlue : .gray
                }
            }
        }
    }


}
