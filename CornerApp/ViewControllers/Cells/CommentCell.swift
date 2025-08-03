import UIKit

class CommentCell: UITableViewCell {
    private let usernameLabel = UILabel()
    private let dateLabel = UILabel()
    private let commentLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    private let likeCountLabel = UILabel()
    
    private var likes = 0

    func configure(with comment: Comment) {
        usernameLabel.text = comment.username
        dateLabel.text = comment.formattedDate
        commentLabel.text = comment.commentText
        likeCountLabel.text = "\(comment.likes)"
        
        likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        likeButton.tintColor = .gray
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        
        layoutUI()
    }
    
    @objc private func likeTapped() {
        likes += 1
        likeCountLabel.text = "\(likes)"
    }

    private func layoutUI() {
        [usernameLabel, dateLabel, commentLabel, likeButton, likeCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

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
}
