//
//  SavedListViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/13.
//

import Observation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Observable
class SavedPostsViewModel {
    var savedLogs: [Log] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchSavedLogs()
    }
    
    func fetchSavedLogs() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("posts")
            .whereField("savedUserIds", arrayContains: currentUid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ 保存済み投稿の取得エラー: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.savedLogs = documents.compactMap { try? $0.data(as: Log.self) }
            }
    }
    
    func fetchUser(userId: String) async throws -> User {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        return try snapshot.data(as: User.self)
    }
}
