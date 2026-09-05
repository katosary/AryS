//
//  OtherProfileViewModel.swift
//  snsmvvm
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
        prosweetness: 0,
        proflavor: 0,
        flavorTags: [],
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
    
    // --- 追加: リモート画像保持用プロパティ ---
    var remoteProfileImage: UIImage? = nil
    var remoteToolImage: UIImage? = nil
    var remoteLogImages: [String: UIImage] = [:] // [LogId: UIImage]
    
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
                // ユーザー情報取得後に画像をロード
                loadRemoteImages()
            } else {
                self.errorMessage = "ユーザーデータが見つかりませんでした。"
            }
             
            let logSnapshot = try await db.collection("posts")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
             
            self.logs = logSnapshot.documents.compactMap { document in
                do {
                    let log = try document.data(as: Log.self)
                    return log
                } catch {
                    print("DEBUG: Logのデコードエラー (ID: \(document.documentID)): \(error)")
                    return nil
                }
            }
            
            // ログの画像もロード
            loadLogImages()
             
        } catch {
            self.errorMessage = "データの取得に失敗しました: \(error.localizedDescription)"
            print("DEBUG: データ取得全体の例外エラー: \(error)")
        }
         
        isLoading = false
    }
    
    // --- 追加: プロフィール・ツール画像を非同期ロード ---
    private func loadRemoteImages() {
        if let profileUrlStr = user.profileImageUrl, let url = URL(string: profileUrlStr) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run { self.remoteProfileImage = image }
                    }
                } catch {
                    print("⚠️ 他ユーザープロフィール画像取得エラー: \(error)")
                }
            }
        } else {
            self.remoteProfileImage = nil
        }
        
        if let toolUrlStr = user.favoriteToolImageUrl, let url = URL(string: toolUrlStr) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run { self.remoteToolImage = image }
                    }
                } catch {
                    print("⚠️ 他ユーザーツール画像取得エラー: \(error)")
                }
            }
        } else {
            self.remoteToolImage = nil
        }
    }
    
    // --- 追加: 投稿一覧の画像を非同期ロード ---
    private func loadLogImages() {
        for log in logs {
            guard let logId = log.id, let imageUrlStr = log.imageUrl, let url = URL(string: imageUrlStr) else { continue }
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            self.remoteLogImages[logId] = image
                        }
                    }
                } catch {
                    print("⚠️ ログ画像取得エラー (\(logId)): \(error)")
                }
            }
        }
    }
    
    /// 投稿削除用
    func deleteLog(targetPost: Log) {
        guard let logId = targetPost.id,
              let currentUserId = Auth.auth().currentUser?.uid,
              targetPost.userId == currentUserId else { return }
        
        Task {
            do {
                try await db.collection("posts").document(logId).delete()
                logs.removeAll { $0.id == logId }
                remoteLogImages.removeValue(forKey: logId)
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
    
    // MARK: - ブロック機能
    func blockUser(targetUserId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let currentUserRef = db.collection("users").document(currentUserId)
            try await currentUserRef.updateData([
                "blockedUserIds": FieldValue.arrayUnion([targetUserId])
            ])
            print("ユーザーをブロックしました: \(targetUserId)")
        } catch {
            print("ブロックの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 通報機能
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
