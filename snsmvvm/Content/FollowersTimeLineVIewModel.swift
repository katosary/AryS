//
//  FollowersTimeLineViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/04.
//

import Observation
import SwiftUI
import FirebaseFirestore

@Observable
@MainActor
class FollowersTimeLineViewModel {
    var logs: [Log] = []
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {}
    
    deinit {
        stopListening()
    }
    
    // MARK: - Realtime Listener
    
    /// 全ユーザーの投稿を新しい順にリアルタイム監視する
    func startListeningAllLogs() {
        // 既存のリスナーがあれば重複して張らないように解除
        stopListening()
        
        listenerRegistration = db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
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
    
    /// リスナーを停止する
    nonisolated func stopListening() {
        // Firestoreのremove()はスレッドセーフ
    }
    
    // MARK: - Fetch User
    
    /// 投稿者のユーザー情報をFirestoreから単発取得する
    func fetchUser(userId: String) async throws -> User {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        let user = try snapshot.data(as: User.self)
        return user
    }
    
    // MARK: - Delete Log
    
    /// 投稿を削除する
    func deleteLog(targetPost: Log) {
        guard let postId = targetPost.id else { return }
        
        db.collection("posts").document(postId).delete { error in
            if let error = error {
                print("❌ 投稿の削除に失敗しました: \(error.localizedDescription)")
            } else {
                print("✅ 投稿を削除しました")
            }
        }
    }
}
