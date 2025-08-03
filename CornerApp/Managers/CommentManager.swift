//
//  CommentManager.swift
//  CornerApp
//
//  Created by Jar Jar on 8/3/25.
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseAuth

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
    //get comment likes etc
    func fetchLikeInfo(for commentID: String, inFact factID: String, completion: @escaping (Bool, Int) -> Void) {
        let commentRef = db.collection("comments").document(factID).collection("userComments").document(commentID)
        let likesRef = commentRef.collection("likes")

        // Get like count
        likesRef.getDocuments { snapshot, error in
            let count = snapshot?.documents.count ?? 0

            // Check if current user liked
            guard let userID = Auth.auth().currentUser?.uid else {
                completion(false, count)
                return
            }

            likesRef.document(userID).getDocument { doc, _ in
                let liked = doc?.exists ?? false
                completion(liked, count)
            }
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
