//
//  AppUser.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/11.
//

import FirebaseFirestore
import Combine
import FirebaseAuth

// 1. AppUser: 構造体自体はそのまま（Sendable準拠でOK）
struct AppUser: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    let email: String
    let createdAt: Date
}

// 2. UserManager: @MainActor を付与して UI更新を保証
@MainActor
class UserManager: ObservableObject {
    @Published var currentUser: AppUser?
    private var db = Firestore.firestore()

    // 3. 非同期メソッドに書き換え
    func fetchCurrentUser(uid: String) async {
        do {
            let docRef = db.collection("users").document(uid)
            // async/await を使用して安全にデータを取得・デコード
            let user = try await docRef.getDocument(as: AppUser.self)
            
            // @MainActor のおかげで直接更新可能
            self.currentUser = user
        } catch {
            print("ユーザー取得エラー: \(error.localizedDescription)")
        }
    }
}
