import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Observable
class CoffeeLogViewModel {
    var log: Log
    var bookmarkManager: BookmarkManager? // オプショナル
    var shouldNavigateToProfile: Bool = false
    var onEdit: () -> Void
    
    private let db = Firestore.firestore()
    
    init(log: Log, bookmarkManager: BookmarkManager? = nil, onEdit: @escaping () -> Void = {}) {
        self.log = log
        self.bookmarkManager = bookmarkManager
        self.onEdit = onEdit
    }
    
    private var currentUid: String? {
        Auth.auth().currentUser?.uid
    }
    
    var isMyPost: Bool {
        guard let currentUid else { return false }
        return log.userId == currentUid
    }
    
    var isLikedByMe: Bool {
        guard let currentUid else { return false }
        return log.likedUserIds.contains(currentUid)
    }
    
    // MARK: - Firebase アクションメソッド
    
    /// いいねの切り替え
    func toggleLike() {
        guard let currentUid, let logId = log.id else { return }
        
        // 楽観的UI更新（すぐに画面側の見た目を反映させる）
        let previousState = isLikedByMe
        let previousCount = log.likesCount
        
        if previousState {
            log.likedUserIds.removeAll { $0 == currentUid }
            log.likesCount = max(0, log.likesCount - 1)
        } else {
            log.likedUserIds.append(currentUid)
            log.likesCount += 1
        }
        
        // Firestoreの更新
        let postRef = db.collection("posts").document(logId)
        
        Task {
            do {
                if previousState {
                    // いいね解除
                    try await postRef.updateData([
                        "likedUserIds": FieldValue.arrayRemove([currentUid]),
                        "likesCount": FieldValue.increment(Int64(-1))
                    ])
                } else {
                    // いいね追加
                    try await postRef.updateData([
                        "likedUserIds": FieldValue.arrayUnion([currentUid]),
                        "likesCount": FieldValue.increment(Int64(1))
                    ])
                }
            } catch {
                // エラー時は状態をロールバック
                DispatchQueue.main.async {
                    if previousState {
                        self.log.likedUserIds.append(currentUid)
                        self.log.likesCount = previousCount
                    } else {
                        self.log.likedUserIds.removeAll { $0 == currentUid }
                        self.log.likesCount = previousCount
                    }
                }
                print("Failed to toggle like: \(error.localizedDescription)")
            }
        }
    }
    
    func toggleSave(bookmarkManager: BookmarkManager) {
            guard let logId = log.id else { return }
            bookmarkManager.toggleSave(for: logId)
        }
    
    /// プロフィール押下時
    func onTapProfile() {
        shouldNavigateToProfile = true
    }
    
    /// 削除処理
    func deletePost() {
        guard let logId = log.id else { return }
        
        Task {
            do {
                try await db.collection("posts").document(logId).delete()
                print("投稿を削除しました: \(logId)")
            } catch {
                print("Failed to delete post: \(error.localizedDescription)")
            }
        }
    }
}
