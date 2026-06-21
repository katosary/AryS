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
    // 💡 型を AppUser から User に変更
    @Published var currentUser: User?
    private var db = Firestore.firestore()

    func fetchCurrentUser(uid: String) async {
        print("取得開始: \(uid)")
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if doc.exists {
                print("データ発見！")
                // 💡 ここも User.self を指定しているのでこれでOKです
                self.currentUser = try doc.data(as: User.self)
            } else {
                print("データなし！ドキュメントIDがuidと違っていませんか？")
            }
        } catch {
            print("エラー詳細: \(error)")
        }
    }
}
