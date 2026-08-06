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
    
    // 💡 リアルタイムリスナーを保持するプロパティを追加
    private var listener: ListenerRegistration?

    // 💡 1回限りの取得 (fetchUserLogs) から、リアルタイム監視 (startListening) に変更
    func startListeningUserLogs() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 既存のリスナーがあれば一度解除して重複を防ぐ
        listener?.remove()
        
        // addSnapshotListenerに変更してリアルタイムで変更を検知する
        listener = db.collection("posts")
            .whereField("userId", isEqualTo: uid)
            // .order(by: "createdAt", descending: true) // 必要に応じて並び替え
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("ログの監視に失敗しました: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("ドキュメントが存在しません")
                    return
                }
                
                // 変更があったデータを自動的にデコードして配列を更新
                self.logs = documents.compactMap { document in
                    try? document.data(as: Log.self)
                }
            }
    }

    // 💡 画面が閉じる時などにリスナーを解放するメソッド
    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // ユーザー情報取得用メソッド（変更なし）
    func fetchUser(userId: String) async throws -> User {
        let doc = try await Firestore.firestore().collection("users").document(userId).getDocument()
        return try doc.data(as: User.self)
    }
    
    // deleteLog メソッド（変更なし：削除するとリアルタイムリスナーが自動で検知して配列も更新されます）
    func deleteLog(targetPost: Log) {
        guard let id = targetPost.id else { return }
        Firestore.firestore().collection("posts").document(id).delete() { error in
            if let error = error {
                print("削除に失敗しました: \(error)")
            }
        }
        // ローカル側でも即座に反映させたい場合は残しておいてOKです
        logs.removeAll { $0.id == id }
    }
    
    // デinit時に安全のためリスナーを解除
    deinit {
        stopListening()
    }
}
