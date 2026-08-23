//
//  TimeLineViewModel.swift
//  snsmvvm
//

import Observation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Observable
@MainActor
class TimeLineViewModel {
    var logs: [Log] = []
    var blockedUserIds: [String] = []
    
    private var db = Firestore.firestore()
    private var postsListener: ListenerRegistration?
    private var blocksListener: ListenerRegistration?
    private var allFetchedLogs: [Log] = []
    
    init() {
        listenToBlockedUsersAndPosts()
    }
    
    // Swift 6 の isolated deinit を使って安全にリスナーを解放する
    isolated deinit {
        postsListener?.remove()
        blocksListener?.remove()
    }
    
    /// ブロックユーザーと投稿を同時にリアルタイム監視する
    private func listenToBlockedUsersAndPosts() {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            startListeningPosts()
            return
        }
         
        blocksListener?.remove()
        blocksListener = db.collection("blocks")
            .whereField("blockerId", isEqualTo: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                 
                if let error = error {
                    print("❌ ブロックリスト購読エラー: \(error)")
                    self.startListeningPosts()
                    return
                }
                 
                self.blockedUserIds = snapshot?.documents.compactMap { doc in
                    doc.data()["blockedId"] as? String
                } ?? []
                 
                self.applyFilter()
                 
                if self.postsListener == nil {
                    self.startListeningPosts()
                }
            }
    }
    
    private func startListeningPosts() {
        postsListener?.remove()
         
        postsListener = db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                 
                if let error = error {
                    print("❌ タイムライン取得エラー: \(error)")
                    return
                }
                 
                guard let documents = snapshot?.documents else { return }
                 
                self.allFetchedLogs = documents.compactMap { document in
                    try? document.data(as: Log.self)
                }
                 
                self.applyFilter()
            }
    }
    
    private func applyFilter() {
        self.logs = allFetchedLogs.filter { log in
            !blockedUserIds.contains(log.userId)
        }
    }
    
    // MARK: - Update Local Log (即時反映用)
    func updateLocalLog(_ updatedLog: Log) {
        if let index = logs.firstIndex(where: { $0.id == updatedLog.id }) {
            logs[index] = updatedLog
        }
        if let allIndex = allFetchedLogs.firstIndex(where: { $0.id == updatedLog.id }) {
            allFetchedLogs[allIndex] = updatedLog
        }
    }
    
    // MARK: - Toggle Like
    func toggleLike(for log: Log) {
        guard let postId = log.id, let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let index = logs.firstIndex(where: { $0.id == postId }) else { return }
         
        let isCurrentlyLiked = logs[index].likedUserIds.contains(currentUid)
        let previousLikedUserIds = logs[index].likedUserIds
        let previousLikesCount = logs[index].likesCount
         
        if isCurrentlyLiked {
            logs[index].likedUserIds.removeAll { $0 == currentUid }
            logs[index].likesCount = max(0, logs[index].likesCount - 1)
        } else {
            logs[index].likedUserIds.append(currentUid)
            logs[index].likesCount += 1
        }
         
        let updatedLikedUserIds = logs[index].likedUserIds
        let newCount = logs[index].likesCount
         
        db.collection("posts").document(postId).updateData([
            "likedUserIds": updatedLikedUserIds,
            "likesCount": newCount
        ]) { [weak self] error in
            if let error = error {
                print("❌ いいねの更新に失敗しました: \(error)")
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
        return try snapshot.data(as: User.self)
    }
}
