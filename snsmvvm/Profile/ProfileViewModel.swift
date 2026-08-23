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
            await loadUserData()
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
    
    /// nonisolatedにすることで、deinitなどの非メインアクター環境からも安全にリスナーを破棄できるようにする
    nonisolated private func stopListening() {
        // ListenerRegistrationのremove()自体はスレッドセーフティに配慮されています
    }
    
    // MARK: - Async One-time Fetch
    
    private func fetchProfile(uid: String) async {
        guard !uid.isEmpty else {
            self.errorMessage = "有効なユーザーIDが存在しません。"
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            if snapshot.exists {
                self.user = try snapshot.data(as: User.self)
            } else {
                self.errorMessage = "ユーザーデータが見つかりませんでした。"
            }
        } catch {
            self.errorMessage = "データの取得に失敗しました: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
    
    @MainActor
    func loadUserData() async {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "ログインしていません。"
            return
        }
        await fetchProfile(uid: currentUid)
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
        
        // 理由が空の場合はデフォルト値を設定する
        let finalReason = reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "理由なし（または選択式）" : reason
        
        var reportData: [String: Any] = [
            "reporterId": currentUid,        // 通報した人
            "targetUserId": targetUserId,    // 通報された人
            "reason": finalReason,           // 通報の理由
            "createdAt": FieldValue.serverTimestamp() // 通報日時
        ]
        
        // 投稿IDが存在する場合は含める
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
