//
//  AuthManager.swift
//  AryS
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Observation

@Observable
class AuthManager {
    var isLoggedIn: Bool = false
    var isEmailVerified: Bool = false
    var userType: UserType = .unknown // .general (一般), .store (店舗), .unknown
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    enum UserType {
        case general
        case store
        case unknown
    }
    
    private var auth: Auth {
        return Auth.auth()
    }
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        handle = self.auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoggedIn = (user != nil)
                self.isEmailVerified = user?.isEmailVerified ?? false
                
                if let user = user {
                    // ログイン中の場合、一般ユーザーか店舗ユーザーかを判定する
                    await self.determineUserType(uid: user.uid)
                } else {
                    self.userType = .unknown
                }
            }
        }
    }
    
    deinit {
        if let handle = handle {
            self.auth.removeStateDidChangeListener(handle)
        }
    }
    
    // Firestoreを調べることで、一般か店舗かを判定
    private func determineUserType(uid: String) async {
        let db = Firestore.firestore()
        
        do {
            // 1. まず stores コレクションを確認
            let storeDoc = try await db.collection("stores").document(uid).getDocument()
            if storeDoc.exists {
                self.userType = .store
                return
            }
            
            // 2. 次に users コレクションを確認
            let userDoc = try await db.collection("users").document(uid).getDocument()
            if userDoc.exists {
                self.userType = .general
                return
            }
            
            self.userType = .unknown
        } catch {
            print("ユーザータイプ判定エラー: \(error)")
            self.userType = .unknown
        }
    }
    
    // メール認証状態の再取得
    func checkEmailVerification(completion: @escaping (Bool) -> Void) {
        guard let user = self.auth.currentUser else {
            completion(false)
            return
        }
        
        user.reload { [weak self] error in
            Task { @MainActor in
                if error == nil {
                    let verified = user.isEmailVerified
                    self?.isEmailVerified = verified
                    completion(verified)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - ログイン処理
    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        self.auth.signIn(withEmail: email, password: password) { _, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.userNotFound.rawValue || error.code == AuthErrorCode.invalidCredential.rawValue {
                    completion("登録されていないメールアドレス、またはパスワードが間違っています。")
                } else {
                    completion(error.localizedDescription)
                }
            } else {
                completion(nil) // 成功
            }
        }
    }
    
    // MARK: - 新規登録処理（確認メール送信 ＆ Firestoreへの保存）
    func signUp(
        email: String,
        password: String,
        name: String,
        age: Int,
        prefecture: String,
        addressDetail: String,
        probitter: Int,
        proacidity: Int,
        probody: Int,
        prosweetness: Int,
        proflavor: Int,
        selectedFlavors: [String],
        completion: @escaping (String?) -> Void
    ) {
        self.auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                completion("ユーザーの作成に失敗しました。")
                return
            }
            
            // 確認メールを送信
            user.sendEmailVerification { error in
                if let error = error {
                    print("確認メールの送信に失敗しました: \(error.localizedDescription)")
                }
            }
            
            // Firestoreへの詳細情報付きユーザー保存処理
            self?.saveUserToFirestore(
                uid: user.uid,
                email: email,
                name: name,
                age: age,
                prefecture: prefecture,
                addressDetail: addressDetail,
                probitter: probitter,
                proacidity: proacidity,
                probody: probody,
                prosweetness: prosweetness,
                proflavor: proflavor,
                selectedFlavors: selectedFlavors,
                completion: completion
            )
        }
    }
    
    // MARK: - Firestoreへのユーザーデータ保存
    private func saveUserToFirestore(
        uid: String,
        email: String,
        name: String,
        age: Int,
        prefecture: String,
        addressDetail: String,
        probitter: Int,
        proacidity: Int,
        probody: Int,
        prosweetness: Int,
        proflavor: Int,
        selectedFlavors: [String],
        completion: @escaping (String?) -> Void
    ) {
        let db = Firestore.firestore()
        let fullAddress = prefecture + addressDetail
        
        let userData: [String: Any] = [
            "userNo": 0,
            "userName": name,
            "userAddress": fullAddress,
            "userPhone": "",
            "email": email,
            "selfIntroduction": "",
            "userAge": age,
            "prefecture": prefecture,
            "favoriteCoffee": "",
            "probitter": probitter,
            "proacidity": proacidity,
            "probody": probody,
            "prosweetness": prosweetness,
            "proflavor": proflavor,
            "flavorTags": selectedFlavors,
            "profileImageUrl": "",
            "favoriteToolImageUrl": ""
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                completion(nil) // 成功
            }
        }
    }
    
    // MARK: - ログアウト共通処理
    func signOut(userManager: UserManager? = nil, profileViewModel: ProfileViewModel? = nil) {
        do {
            try self.auth.signOut()
            Task { @MainActor in
                userManager?.currentUser = nil
                profileViewModel?.reset()
                self.isLoggedIn = false
                self.isEmailVerified = false
                self.userType = .unknown
            }
        } catch {
            print("ログアウトエラー: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 店舗・一般共通のアカウント削除（再認証 & Firestoreデータ削除）
    func deleteAccount(password: String, completion: @escaping (String?) -> Void) {
        guard let user = self.auth.currentUser,
              let email = user.email else {
            completion("ユーザー情報が見つかりませんでした。")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user.reauthenticate(with: credential) { [weak self] _, error in
            if let error = error {
                completion("パスワードが間違っているか、再認証に失敗しました: \(error.localizedDescription)")
                return
            }
            
            let uid = user.uid
            let db = Firestore.firestore()
            
            // ユーザータイプやコレクション（stores / users）に応じて適切なデータを削除
            let collectionName = (self?.userType == .store) ? "stores" : "users"
            
            db.collection(collectionName).document(uid).delete { storeError in
                if let storeError = storeError {
                    print("Firestoreデータ削除エラー: \(storeError.localizedDescription)")
                }
                
                // Firebase Auth からユーザーを削除
                user.delete { deleteError in
                    if let deleteError = deleteError {
                        completion("アカウントの削除に失敗しました: \(deleteError.localizedDescription)")
                    } else {
                        Task { @MainActor in
                            self?.isLoggedIn = false
                            self?.isEmailVerified = false
                            self?.userType = .unknown
                        }
                        completion(nil) // 成功
                    }
                }
            }
        }
    }
}
