//
//  ProfileCoffeeLogViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/19.
//

import Observation
import FirebaseFirestore
import FirebaseAuth

@Observable
class ProfileCoffeeLogViewModel {
    var logs: [Log] = []
    private let db = Firestore.firestore()

    // 💡 データを取得するメソッドがあるか確認する
    func fetchUserLogs() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let snapshot = try await db.collection("posts")
                .whereField("userId", isEqualTo: uid) // 自分の投稿に絞り込む
                // .order(by: "createdAt", descending: true) // 必要に応じて並び替え
                .getDocuments()
            
            self.logs = try snapshot.documents.compactMap { document in
                try document.data(as: Log.self)
            }
        } catch {
            print("ログの取得に失敗しました: \(error)")
        }
    }
    // ユーザー情報取得用メソッド
    func fetchUser(userId: String) async throws -> User {
        let doc = try await Firestore.firestore().collection("users").document(userId).getDocument()
        return try doc.data(as: User.self)
    }
    
    // 💡 deleteLog メソッドを追加
    func deleteLog(targetPost: Log) {
        guard let id = targetPost.id else { return }
        Firestore.firestore().collection("posts").document(id).delete()
        // 必要に応じて logs 配列からも削除する処理を追加
        logs.removeAll { $0.id == id }
    }
}
