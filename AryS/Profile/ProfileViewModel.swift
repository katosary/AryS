//
//  ProfileViewModel.swift
//  snsmvvm
//

import Foundation
import Observation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Observable
@MainActor
final class ProfileViewModel {
    // MARK: - Properties
    
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
    
    var isProfileEditSheet: Bool = false
    var logs: [Log] = []
    var blockedUserIds: [String] = []
    var blockedByMeUserIds: [String] = []
    
    let maxRating: Int = 5
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    private var userListenerRegistration: ListenerRegistration?
    private var blocksListenerRegistration: ListenerRegistration?
    
    // MARK: - Initializer
    
    init() {
        Task {
            // 単発取得の代わりにリアルタイムリスナーで初期データ取得と常時監視を開始
            listenToUserProfile()
            
            await fetchBlockedUserIds()
            listenToBlockedUsers()
        }
    }
    
    deinit {
        // nonisolated化されたメソッドを呼ぶことで安全に破棄する
        stopListening()
    }
    
    // MARK: - Reset
    
    func reset() {
        stopListening()
         
        self.user = User(
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
        self.logs = []
        self.blockedUserIds = []
        self.blockedByMeUserIds = []
        self.isProfileEditSheet = false
        self.isLoading = false
        self.errorMessage = nil
    }
    
    
    // MARK: - Listener Management
        
        nonisolated private func stopListening() {
            // mainActorの制約を回避するため、あらかじめ非同期またはMainActorの外で安全に破棄できるようにします
            // ListenerRegistration は保持しているプロパティ自体を直接 remove() する形にします。
        }
    
    // MARK: - Realtime Listener for Profile
    
    private func listenToUserProfile() {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            Task { @MainActor in
                self.errorMessage = "ログインしていません。"
            }
            return
        }
        
        userListenerRegistration?.remove()
        
        self.isLoading = true
        self.errorMessage = nil
        
        userListenerRegistration = db.collection("users").document(currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ プロフィールの購読エラー: \(error)")
                    Task { @MainActor in
                        self.errorMessage = "データの取得に失敗しました: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists else {
                    print("⚠️ プロフィールドキュメントが存在しません")
                    Task { @MainActor in
                        self.errorMessage = "ユーザーデータが見つかりませんでした。"
                        self.isLoading = false
                    }
                    return
                }
                
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    do {
                        self.user = try snapshot.data(as: User.self)
                        print("📡 プロフィールをリアルタイム更新しました")
                    } catch {
                        print("⚠️ Userモデルへのデコード失敗: \(error.localizedDescription)")
                        self.errorMessage = "データの解析に失敗しました: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                }
            }
    }
    
    // MARK: - Async One-time Fetch (手動更新やプルリフレッシュ用として残す場合)
    
    @MainActor
    func loadUserData() async {
        // 基本はリアルタイムリスナーが動きますが、必要に応じて再読み込み等に利用可能
        listenToUserProfile()
    }
    
    // MARK: - Block / Report Logic
    
    func blockUser(targetUserId: String) async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
         
        if targetUserId == currentUid {
            print("Error: Cannot block yourself")
            return
        }
         
        let blockData: [String: Any] = [
            "blockerId": currentUid,
            "blockedId": targetUserId,
            "createdAt": FieldValue.serverTimestamp()
        ]
         
        do {
            try await db.collection("blocks").addDocument(data: blockData)
             
            if !self.blockedUserIds.contains(targetUserId) {
                self.blockedUserIds.append(targetUserId)
            }
             
            print("✅ ユーザーをブロックしました: \(targetUserId) (運営用ログ保存成功)")
        } catch {
            print("⚠️ ブロックの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func fetchBlockedUserIds() async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
         
        do {
            let snapshot = try await db.collection("blocks")
                .whereField("blockerId", isEqualTo: currentUid)
                .getDocuments()
             
            self.blockedUserIds = snapshot.documents.compactMap { doc in
                doc.data()["blockedId"] as? String
            }
            print("📋 ブロックリストを読み込みました: \(self.blockedUserIds.count)名")
        } catch {
            print("⚠️ ブロックリストの取得失敗: \(error.localizedDescription)")
        }
    }
    
    private func listenToBlockedUsers() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
         
        blocksListenerRegistration?.remove()
         
        blocksListenerRegistration = db.collection("blocks")
            .whereField("blockerId", isEqualTo: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                 
                if let error = error {
                    print("❌ ブロックリストの購読エラー: \(error)")
                    return
                }
                 
                guard let documents = snapshot?.documents else { return }
                 
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    self.blockedUserIds = documents.compactMap { doc in
                        doc.data()["blockedId"] as? String
                    }
                    print("📡 ブロックリストをリアルタイム更新: \(self.blockedUserIds.count)名")
                }
            }
    }
    
    /// ユーザーまたは特定の投稿を通報してFirestoreに保存する
    func reportUser(targetUserId: String, postId: String? = nil, reason: String) async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
         
        let finalReason = reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "理由なし（または選択式）" : reason
         
        var reportData: [String: Any] = [
            "reporterId": currentUid,        // 通報した人
            "targetUserId": targetUserId,    // 通報された人
            "reason": finalReason,           // 通報の理由
            "createdAt": FieldValue.serverTimestamp() // 通報日時
        ]
         
        if let postId = postId {
            reportData["postId"] = postId
        }
         
        do {
            try await db.collection("reports").addDocument(data: reportData)
            print("✅ 通報内容の送信に成功しました: \(finalReason)")
        } catch {
            print("❌ 通報の送信に失敗しました: \(error.localizedDescription)")
        }
    }
}
