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
        favoriteCoffeeImageUrl: nil
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
    
    deinit {
        // ViewModelが解放される際にリスナーを破棄
        stopListening()
    }
    
    // MARK: - Realtime Listener
    
    /// 指定されたUIDのユーザーデータをリアルタイムで購読する
    /// - Parameter uid: 対象ユーザーのFirebase Auth UID
    func listenToProfile(uid: String) {
        guard !uid.isEmpty else {
            self.errorMessage = "有効なユーザーIDが存在しません。"
            return
        }
        
        // 既存のリスナーがあれば解除
        stopListening()
        
        self.isLoading = true
        self.errorMessage = nil
        
        listenerRegistration = db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                Task { @MainActor in
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "データの取得に失敗しました: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let snapshot = snapshot, snapshot.exists else {
                        self.errorMessage = "ユーザーデータが見つかりませんでした。"
                        return
                    }
                    
                    do {
                        // Codableを用いたデコード処理
                        let fetchedUser = try snapshot.data(as: User.self)
                        self.user = fetchedUser
                    } catch {
                        self.errorMessage = "データの解析に失敗しました: \(error.localizedDescription)"
                    }
                }
            }
    }
    
    /// リアルタイムリスナーの購読を停止する
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    // MARK: - Async One-time Fetch
    
    /// 単発でユーザー情報を取得したい場合（非同期処理）
    /// - Parameter uid: 対象ユーザーのFirebase Auth UID
    @MainActor
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
}
