//
//  BookmarkManagers.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/13.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
class BookmarkManager {
    var savedLogIds: Set<String> = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        startListening()
    }
    
    deinit {
        listener?.remove()
    }
    
    // リアルタイムで保存状況を監視（ユーザーごとに完全に分離）
    func startListening() {
        // 既存のリスナーがあれば解除
        listener?.remove()
        savedLogIds.removeAll()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
         
        listener = db.collection("users").document(uid).collection("savedLogs")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ ブックマークの監視に失敗しました: \(error)")
                    return
                }
                let ids = snapshot?.documents.map { $0.documentID } ?? []
                DispatchQueue.main.async {
                    self.savedLogIds = Set(ids)
                }
            }
    }
     
    func isSaved(_ logId: String?) -> Bool {
        guard let logId else { return false }
        return savedLogIds.contains(logId)
    }
    
    // 💡 保存・解除を切り替えるメソッド（楽観적UI更新付き）
    func toggleSave(for logId: String?) {
        guard let logId, let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("users").document(uid).collection("savedLogs").document(logId)
         
        // 楽観的にローカルの状態を即時反転
        if savedLogIds.contains(logId) {
            savedLogIds.remove(logId)
            ref.delete { error in
                if let error = error {
                    print("❌ ブックマーク削除失敗: \(error)")
                    DispatchQueue.main.async { self.savedLogIds.insert(logId) }
                }
            }
        } else {
            savedLogIds.insert(logId)
            ref.setData(["savedAt": Date()]) { error in
                if let error = error {
                    print("❌ ブックマーク保存失敗: \(error)")
                    DispatchQueue.main.async { self.savedLogIds.remove(logId) }
                }
            }
        }
    }
}
