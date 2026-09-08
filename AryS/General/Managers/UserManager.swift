//
//  AppUser.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/11.
//

import FirebaseFirestore
import FirebaseAuth
import Observation

@Observable
class UserManager {
    var currentUser: User? 
    private var db = Firestore.firestore()

    func fetchCurrentUser(uid: String) async {
        print("取得開始: \(uid)")
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if doc.exists {
                print("データ発見！")
                self.currentUser = try doc.data(as: User.self)
            } else {
                print("データなし！")
            }
        } catch {
            print("エラー詳細: \(error)")
        }
    }
}
