//
//  ProfileCoffeeLogViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/19.
//

import Observation
import FirebaseFirestore

@Observable
class ProfileCoffeeLogViewModel {
    // 💡 logs プロパティを追加
    var logs: [Log] = []
    
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
