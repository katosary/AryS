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
     
    // MARK: - Toggle Like (楽観的UI更新を適用)
        func toggleLike(for log: Log) {
            guard let postId = log.id, let currentUid = Auth.auth().currentUser?.uid else { return }
            
            // 1. 配列の中から該当のログを探して、即座にローカルの配列（UI）を更新する
            guard let index = logs.firstIndex(where: { $0.id == postId }) else { return }
            
            let isCurrentlyLiked = logs[index].likedUserIds.contains(currentUid)
            
            // バックアップ（失敗時のロールバック用）
            let previousLikedUserIds = logs[index].likedUserIds
            let previousLikesCount = logs[index].likesCount // プロパティ名が likesCount または likeCount に合わせて調整してください
            
            // ローカルの状態を即時反転
            if isCurrentlyLiked {
                logs[index].likedUserIds.removeAll { $0 == currentUid }
                logs[index].likesCount = max(0, logs[index].likesCount - 1)
            } else {
                logs[index].likedUserIds.append(currentUid)
                logs[index].likesCount += 1
            }
            
            let updatedLikedUserIds = logs[index].likedUserIds
            let newCount = logs[index].likesCount
            
            let postRef = db.collection("posts").document(postId)
            
            // 2. バックグラウンドでFirestoreへ非同期送信
            postRef.updateData([
                "likedUserIds": updatedLikedUserIds,
                "likesCount": newCount
            ]) { [weak self] error in
                if let error = error {
                    print("❌ いいねの更新に失敗しました: \(error)")
                    
                    // 3. 失敗した場合はメインスレッドで元の状態に戻す（ロールバック）
                    Task { @MainActor [weak self] in
                        guard let self = self, let currentIndex = self.logs.firstIndex(where: { $0.id == postId }) else { return }
                        self.logs[currentIndex].likedUserIds = previousLikedUserIds
                        self.logs[currentIndex].likesCount = previousLikesCount
                    }
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
