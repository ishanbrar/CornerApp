import UIKit
import FirebaseAuth
import FirebaseFirestore

class CommentCell: UITableViewCell {
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
        dateLabel.text = comment.formattedDate
        commentLabel.text = comment.commentText
        likeCountLabel.text = "\(comment.likeCount)"
        
        updateLikeButtonState()
    }

    private func layoutUI() {
        [usernameLabel, dateLabel, commentLabel, likeButton, likeCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        likeButton.tintColor = .gray
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            dateLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            commentLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            commentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            likeButton.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 8),
            likeButton.leadingAnchor.constraint(equalTo: commentLabel.leadingAnchor),
            
            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 4),
            likeCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    @objc private func likeButtonTapped() {
        guard var comment = currentComment,
              let factID = currentFactID,
              let userID = Auth.auth().currentUser?.uid,
              let commentID = comment.id else {
            print("❌ Missing data")
            return
        }

        let db = Firestore.firestore()
        let ref = db.collection("comments")
            .document(factID)
            .collection("userComments")
            .document(commentID)
            .collection("likes")
            .document(userID)

        let isLiked = comment.likedByCurrentUser ?? false

        if isLiked {
            ref.delete { error in
                if let error = error {
                    print("❌ Error unliking comment: \(error)")
                } else {
                    comment.likedByCurrentUser = false
                    comment.likeCount -= 1
                    self.currentComment = comment
                    DispatchQueue.main.async {
                        self.updateLikeButtonState()
                    }
                }
            }
        } else {
            ref.setData(["liked": true]) { error in
                if let error = error {
                    print("❌ Error liking comment: \(error)")
                } else {
                    comment.likedByCurrentUser = true
                    comment.likeCount += 1
                    self.currentComment = comment
                    DispatchQueue.main.async {
                        self.updateLikeButtonState()
                    }
                }
            }
        }
    }


    private func updateLikeButtonState() {
        let liked = currentComment?.likedByCurrentUser ?? false
        let count = currentComment?.likeCount ?? 0
        likeCountLabel.text = "\(count)"
        likeButton.tintColor = liked ? .systemBlue : .gray
    }
}
