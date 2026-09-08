//
//  StoreCustomerPostsViewModel.swift
//  ArySStore
//

import Observation
import SwiftUI
//import FirebaseFirestore
//import FirebaseAuth

@Observable
@MainActor
class StoreTimeLineViewModel {
//    var logs: [Log] = []
//    
//    private var db = Firestore.firestore()
//    private var postsListener: ListenerRegistration?
//    private var allFetchedLogs: [Log] = []
//    
//    init() {
//        startListeningStorePosts()
//    }
//    
//    isolated deinit {
//        postsListener?.remove()
//    }
//    
//    /// ログイン中の店舗UIDに紐づく投稿をリアルタイム監視する
//    private func startListeningStorePosts() {
//        postsListener?.remove()
//        
//        // 💡 ログインしている店舗自身のUIDを取得
//        guard let storeUid = Auth.auth().currentUser?.uid else {
//            print("❌ ログイン中の店舗UIDが取得できません")
//            return
//        }
//        
//        // Firestoreの構造に合わせてフィールド名を調整してください（例: "storeId" や "selectedStoreId" など）
//        postsListener = db.collection("posts")
//            .whereField("storeId", isEqualTo: storeUid)
//            .order(by: "createdAt", descending: true)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else { return }
//                
//                if let error = error {
//                    print("❌ 店舗向け投稿の取得エラー: \(error)")
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else { return }
//                
//                self.logs = documents.compactMap { document in
//                    try? document.data(as: Log.self)
//                }
//                
//                print("✅ 自店舗宛ての投稿を \(self.logs.count) 件取得しました")
//            }
//    }
//    
//    // MARK: - Fetch User (投稿者の一般ユーザー情報を取得)
//    func fetchUser(userId: String) async throws -> User {
//        let snapshot = try await db.collection("users").document(userId).getDocument()
//        return try snapshot.data(as: User.self)
//    }
}
