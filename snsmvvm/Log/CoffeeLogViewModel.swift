//
//  CoffeeLogViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//


import Observation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Observable
class CoffeeLogViewModel {
    // MARK: - プロパティ
    var logs: [Log] = []
    private var db = Firestore.firestore()
    
    // MARK: - 初期化
    init() {
        fetchLogs()
    }
    
    // MARK: - ログの取得・監視
    func fetchLogs() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("posts")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ データ取得エラー: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.logs = documents.compactMap { document in
                    try? document.data(as: Log.self)
                }
            }
    }
    
    // MARK: - ログの削除
    func deleteLog(targetPost: Log) {
        guard let id = targetPost.id else { return }
        
        // Firestoreから削除
        db.collection("posts").document(id).delete { error in
            if let error = error {
                print("❌ 削除失敗: \(error)")
            } else {
                print("✅ 削除成功")
            }
        }
    }
}
