import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class CommentManager {
    static let shared = CommentManager()
    private init() {}

    private let db = Firestore.firestore()

    // Fetch comments for a specific fact
    func fetchComments(forFactID factID: String, completion: @escaping ([Comment]) -> Void) {
        db.collection("comments")
            .document(factID)
            .collection("userComments")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching comments: \(error)")
                    completion([])
                    return
                }

                let comments = snapshot?.documents.compactMap {
                    try? $0.data(as: Comment.self)
                } ?? []
                completion(comments)
            }
    }

    // Add a comment to a fact
    func addComment(toFactID factID: String, comment: Comment, completion: @escaping (Error?) -> Void) {
        do {
            _ = try db.collection("comments")
                .document(factID)
                .collection("userComments")
                .addDocument(from: comment, completion: completion)
        } catch {
            completion(error)
        }
    }

    // Increment likes for a comment
    func likeComment(factID: String, commentID: String, completion: ((Error?) -> Void)? = nil) {
        let ref = db.collection("comments")
            .document(factID)
            .collection("userComments")
            .document(commentID)

        ref.updateData([
            "likes": FieldValue.increment(Int64(1))
        ], completion: completion)
    }
}
