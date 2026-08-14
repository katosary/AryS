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
                // 1. ユーザー情報の取得
                let userSnapshot = try await db.collection("users").document(userId).getDocument()
                if userSnapshot.exists {
                    self.user = try userSnapshot.data(as: User.self)
                } else {
                    self.errorMessage = "ユーザーデータが見つかりませんでした。"
                }
                 
                // 2. そのユーザーの投稿ログの取得（コレクション名を "logs" から "posts" に修正）
                let logSnapshot = try await db.collection("posts")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                 
                self.logs = logSnapshot.documents.compactMap { document in
                    try? document.data(as: Log.self)
                }
                // 必要に応じて日付順にソートする場合
                // self.logs.sort(by: { $0.createdAt > $1.createdAt })
                 
            } catch {
                self.errorMessage = "データの取得に失敗しました: \(error.localizedDescription)"
            }
             
            isLoading = false
        }
         
        /// 投稿削除用（必要に応じて）
        func deleteLog(targetPost: Log) {
            guard let logId = targetPost.id else { return }
            Task {
                do {
                    // こちらも削除対象のコレクション名を "logs" から "posts" に修正
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
}
