import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

struct Comment: Codable {
    @DocumentID var id: String?
    var username: String
    var commentText: String
    var timestamp: Date
    var likeCount: Int
    var likedByCurrentUser: Bool? = false

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
