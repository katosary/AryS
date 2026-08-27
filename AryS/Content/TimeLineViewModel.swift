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
        
        // 💡 ここで logs の id 一覧と重複がないかチェックする
        print("--- 📋 ログのID一覧チェック ---")
        let ids = self.logs.compactMap { $0.id }
        for (index, id) in ids.enumerated() {
            print("index[\(index)]: ID = \(id)")
        }
        
        // 重複があるかどうかの判定
        let uniqueIds = Set(ids)
        if ids.count != uniqueIds.count {
            print("❌ 警告: IDの重複があります！！")
        } else {
            print("✅ IDはすべてユニーク（正常）です")
        }
    }
     
    // MARK: - Update Local Log (即時反映用)
    func updateLocalLog(_ updatedLog: Log) {
        // 💡 配列の参照自体を新しくしてSwiftUIに変更を確実に検知させる
        if let index = logs.firstIndex(where: { $0.id == updatedLog.id }) {
            var newLogs = logs
            newLogs[index] = updatedLog
            self.logs = newLogs
        }
         
        if let allIndex = allFetchedLogs.firstIndex(where: { $0.id == updatedLog.id }) {
            var newAllLogs = allFetchedLogs
            newAllLogs[allIndex] = updatedLog
            self.allFetchedLogs = newAllLogs
        }
    }
     
         
    // MARK: - Fetch User
    func fetchUser(userId: String) async throws -> User {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        return try snapshot.data(as: User.self)
    }
}
