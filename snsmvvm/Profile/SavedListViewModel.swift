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
class SavedListViewModel {
    var savedLogs: [Log] = []
    private let db = Firestore.firestore()
         
    init() {
        // 初期化時
    }
         
    // 💡 ここにユーザー取得用のメソッドを追加する
    func fetchUser(userId: String) async throws -> User {
        let doc = try await db.collection("users").document(userId).getDocument()
        return try doc.data(as: User.self)
    }

    func fetchSavedPosts(with logIds: Set<String>) {
        // (既存のコードそのまま)
        guard !logIds.isEmpty else {
            DispatchQueue.main.async {
                self.savedLogs = []
            }
            return
        }
             
        Task {
            var fetchedLogs: [Log] = []
            for id in logIds {
                do {
                    let doc = try await db.collection("posts").document(id).getDocument()
                    if let log = try? doc.data(as: Log.self) {
                        fetchedLogs.append(log)
                    }
                } catch {
                    print("Failed to fetch post \(id): \(error.localizedDescription)")
                }
            }
                 
            DispatchQueue.main.async {
                self.savedLogs = fetchedLogs
            }
        }
    }
}
