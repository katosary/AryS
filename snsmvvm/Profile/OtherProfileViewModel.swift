//
//  OtherProfileViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/14.
//

import Foundation
import Observation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Observable
@MainActor
final class OtherProfileViewModel {
    var user: User = User(
        id: nil,
        userNo: 1,
        userName: "",
        email: "",
        selfIntroduction: "",
        userAge: 0,
        prefecture: "",
        favoriteCoffee: "",
        probitter: 0,
        proacidity: 0,
        probody: 0,
        proaroma: 0,
        proflavor: "",
        dripper: "",
        paperFilter: "",
        kettle: "",
        server: "",
        scale: "",
        mill: "",
        grinder: "",
        espressoMachine: "",
        frenchPress: "",
        profileImageUrl: nil,
        favoriteToolImageUrl: nil
    )
    
    var logs: [Log] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    /// 指定されたUIDのユーザープロフィールと投稿ログを同時に取得する
    func loadUserData(userId: String) async {
        guard !userId.isEmpty else {
            self.errorMessage = "有効なユーザーIDではありません。"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let userSnapshot = try await db.collection("users").document(userId).getDocument()
            if userSnapshot.exists {
                self.user = try userSnapshot.data(as: User.self)
            } else {
                self.errorMessage = "ユーザーデータが見つかりませんでした。"
            }
            
            let logSnapshot = try await db.collection("posts")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            self.logs = logSnapshot.documents.compactMap { document in
                try? document.data(as: Log.self)
            }
            
        } catch {
            self.errorMessage = "データの取得に失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// 投稿削除用
    func deleteLog(targetPost: Log) {
        guard let logId = targetPost.id else { return }
        Task {
            do {
                try await db.collection("posts").document(logId).delete()
                logs.removeAll { $0.id == logId }
            } catch {
                print("Failed to delete log: \(error)")
            }
        }
    }
    
    /// 投稿内の他ユーザー情報取得用
    func fetchUser(userId: String) async throws -> User {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    // MARK: - ブロック機能の追加
    func blockUser(targetUserId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            // 自分のドキュメントに blockedUserIds 配列として追加 (ArrayUnionを使用)
            let currentUserRef = db.collection("users").document(currentUserId)
            try await currentUserRef.updateData([
                "blockedUserIds": FieldValue.arrayUnion([targetUserId])
            ])
            print("ユーザーをブロックしました: \(targetUserId)")
        } catch {
            print("ブロックの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 通報機能の追加
    func reportUser(targetUserId: String, reason: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let reportData: [String: Any] = [
            "reporterId": currentUserId,
            "targetUserId": targetUserId,
            "reason": reason.isEmpty ? "理由なし" : reason,
            "createdAt": Timestamp()
        ]
        
        do {
            try await db.collection("reports").addDocument(data: reportData)
            print("ユーザーを通報しました: \(targetUserId)")
        } catch {
            print("通報の送信に失敗しました: \(error.localizedDescription)")
        }
    }
}
