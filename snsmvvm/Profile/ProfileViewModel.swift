//
//  ProfileViewModel.swift
//  snsmvvm
//

import Observation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Observable
class ProfileViewModel {
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    // 💡 状態は user オブジェクトに一元化（二重管理プロパティを削除）
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
    
    var logs: [Log] = []
    var profileImage: UIImage?
    var favoriteCoffeeImage: UIImage?
    var isProfileEditSheet: Bool = false
    
    // UI表示用スター関連設定
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    
    var myLogs: [Log] {
        let currentUid = Auth.auth().currentUser?.uid
        return logs.filter { $0.userId == currentUid }
    }
    
    deinit {
        // ViewModel破棄時にリスナーを安全に解除
        listenerRegistration?.remove()
    }
    
    // MARK: - リアルタイムリスナー
    
    /// Firestoreのドキュメント更新を常時監視・即時反映する
    func listenToProfile(uid: String) {
        // 重複登録を防止
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ プロフィール読み込みエラー: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists else {
                    print("⚠️ ユーザーデータが存在しません")
                    return
                }
                
                do {
                    // Firestoreのドキュメントを User 型にデコード
                    let fetchedUser = try snapshot.data(as: User.self)
                    
                    Task { @MainActor in
                        // user が更新されると、@Observable により参照している View が即座に自動再描画される
                        self.user = fetchedUser
                    }
                } catch {
                    print("❌ デコード失敗: \(error)")
                }
            }
    }
    
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    // MARK: - 補助メソッド
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
}
