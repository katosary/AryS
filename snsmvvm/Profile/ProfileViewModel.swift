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
    
    /// 画面に表示するユーザー情報
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
        flavorTags: [],         // ← proflavorTags から flavorTags に修正
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
    
    let maxRating: Int = 5
    /// ローディング状態管理
    var isLoading: Bool = false
    
    /// エラーハンドリング用
    var errorMessage: String? = nil
    
    // Firestoreおよびリスナー管理
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    // MARK: - Initializer
    
    init() {}
    
//    deinit {
//        // ViewModelが解放される際にリスナーを破棄
//        stopListening()
//    }
    
    // MARK: - Reset (💡 ログアウト時用に追加)
    
    /// ログアウト時などに保持しているデータをすべてリセットし、リスナーを停止する
    func reset() {
//        stopListening() // 前のユーザーのリアルタイム監視を必ず止める
        
        // ユーザー情報を初期値に戻す
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
            flavorTags: [],     // ← proflavorTags から flavorTags に修正
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
        self.isProfileEditSheet = false
        self.isLoading = false
        self.errorMessage = nil
    }
    
//    // MARK: - Realtime Listener
//
//    /// 指定されたUIDのユーザーデータをリアルタイムで購読する
//    /// - Parameter uid: 対象ユーザーのFirebase Auth UID
//    func listenToProfile(uid: String) {
//        guard !uid.isEmpty else {
//            self.errorMessage = "有効なユーザーIDが存在しません。"
//            return
//        }
//
//        // 既存のリスナーがあれば解除
//        stopListening()
//
//        self.isLoading = true
//        self.errorMessage = nil
//
//        listenerRegistration = db.collection("users").document(uid)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else { return }
//
//                // @Observableクラスなので、Task @MainActorで安全にプロパティを更新
//                Task { @MainActor in
//                    self.isLoading = false
//
//                    if let error = error {
//                        self.errorMessage = "データの取得に失敗しました: \(error.localizedDescription)"
//                        return
//                    }
//
//                    guard let snapshot = snapshot, snapshot.exists else {
//                        self.errorMessage = "ユーザーデータが見つかりませんでした。"
//                        return
//                    }
//
//                    do {
//                        // Codableを用いたデコード処理
//                        let fetchedUser = try snapshot.data(as: User.self)
//                        self.user = fetchedUser
//                    } catch {
//                        self.errorMessage = "データの解析に失敗しました: \(error.localizedDescription)"
//                    }
//                }
//            }
//    }
//
//    /// リアルタイムリスナーの購読を停止する
//        nonisolated func stopListening() {
//            // 主にメインスレッド外や deinit からも安全に呼ばれるようにする
//            // listenerRegistrationの操作はFirebaseのAPIでスレッドセーフなため問題ありません
//        }
//
    // MARK: - Async One-time Fetch
    
    /// 単発でユーザー情報を取得したい場合（非同期処理）
    /// - Parameter uid: 対象ユーザーのFirebase Auth UID
    func fetchProfile(uid: String) async {
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
        // ログイン中のユーザーID（UID）を安全に取り出す
        guard let currentUid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "ログインしていません。"
            return
        }
         
        // 既存の fetchProfile を呼び出す
        await fetchProfile(uid: currentUid)
    }
    
    // MARK: - ブロック機能
    func blockUser(targetUserId: String) async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
         
        do {
            let currentUserRef = db.collection("users").document(currentUid)
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
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
         
        let reportData: [String: Any] = [
            "reporterId": currentUid,
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
