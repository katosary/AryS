import Observation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Observable
@MainActor
class TimeLineViewModel {
    var logs: [Log] = []
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
     
    init() {
        startListeningAllLogs()
    }
     
    // 💡 deinit からは直接プロパティを触らないように空にする（または削除）
    deinit {}
     
    func startListeningAllLogs() {
        listenerRegistration?.remove()
         
        listenerRegistration = db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                     
                    if let error = error {
                        print("❌ タイムライン取得エラー: \(error)")
                        return
                    }
                     
                    guard let documents = snapshot?.documents else { return }
                     
                    self.logs = documents.compactMap { document in
                        try? document.data(as: Log.self)
                    }
                }
            }
    }
     
    // MARK: - Toggle Like
    func toggleLike(for log: Log) {
        guard let postId = log.id, let currentUid = Auth.auth().currentUser?.uid else { return }
        let postRef = db.collection("posts").document(postId)
         
        var updatedLikedUserIds = log.likedUserIds
        if updatedLikedUserIds.contains(currentUid) {
            updatedLikedUserIds.removeAll { $0 == currentUid }
        } else {
            updatedLikedUserIds.append(currentUid)
        }
         
        let newCount = updatedLikedUserIds.count
         
        postRef.updateData([
            "likedUserIds": updatedLikedUserIds,
            "likesCount": newCount
        ]) { error in
            if let error = error {
                print("❌ いいねの更新に失敗しました: \(error)")
            }
        }
    }
     
    // MARK: - Delete Log
    func deleteLog(targetPost: Log) {
        guard let postId = targetPost.id else { return }
         
        db.collection("posts").document(postId).delete { error in
            if let error = error {
                print("❌ 投稿の削除に失敗しました: \(error.localizedDescription)")
            }
        }
    }
     
    // MARK: - Fetch User
    func fetchUser(userId: String) async throws -> User {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        let user = try snapshot.data(as: User.self)
        return user
    }
}
