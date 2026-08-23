//
//  AuthManager.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/07.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    private var handle: AuthStateDidChangeListenerHandle?
    
    // ゲッター: アクセスする瞬間に Auth.auth() を呼び出す
    private var auth: Auth {
        return Auth.auth()
    }
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        handle = self.auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isLoggedIn = (user != nil)
            }
        }
    }
    
    deinit {
        if let handle = handle {
            self.auth.removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - ログイン処理（未登録のメールアドレスやパスワード違いをハンドリング）
    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        self.auth.signIn(withEmail: email, password: password) { _, error in
            if let error = error as NSError? {
                // 未登録のメールアドレス、または認証情報の不一致エラーを判定
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
    
    // MARK: - 新規登録処理（氏名・住所・電話番号などを一緒にFirestoreへ保存）
    func signUp(
        email: String,
        password: String,
        name: String,
        address: String,
        phone: String,
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
             
            // Firestoreへの詳細情報付きユーザー保存処理
            self?.saveUserToFirestore(
                uid: user.uid,
                email: email,
                name: name,
                address: address,
                phone: phone,
                completion: completion
            )
        }
    }
    
    // MARK: - Firestoreへのユーザーデータ保存
    private func saveUserToFirestore(
        uid: String,
        email: String,
        name: String,
        address: String,
        phone: String,
        completion: @escaping (String?) -> Void
    ) {
        let db = Firestore.firestore()
         
        let userData: [String: Any] = [
            "userNo": 0,
            "userName": name,
            "userAddress": address,
            "userPhone": phone,
            "email": email,
            "selfIntroduction": "",
            "userAge": 0,
            "prefecture": "",
            "favoriteCoffee": "",
            "probitter": 0,
            "proacidity": 0,
            "probody": 0,
            "proaroma": 0,
            "proflavor": ""
        ]
         
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                completion(nil) // 成功
            }
        }
    }
    
    // MARK: - 投稿ログの保存処理
    func saveLogToFirestore(
        shopName: String,
        blend: String,
        countryName: String,
        farmName: String,
        grade: String,
        roastLevel: String,
        aromarating: Int,
        memo: String,
        bitternessrating: Int,
        acidityrating: Int,
        bodyrating: Int,
        sweetnessrating: Int,
        flavorTags: [String],
        tagX: CGFloat,
        tagY: CGFloat,
        imageUrl: String?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let db = Firestore.firestore()

        let newLog = Log(
            userId: uid,
            shopName: shopName,
            blend: blend,
            countryName: countryName,
            farmName: farmName,
            grade: grade,
            roastLevel: roastLevel,
            flavorrating: aromarating,
            memo: memo,
            bitternessrating: bitternessrating,
            acidityrating: acidityrating,
            bodyrating: bodyrating,
            sweetnessrating: sweetnessrating,
            flavorTags: flavorTags,
            createdAt: Date(),
            tagX: tagX,
            tagY: tagY,
            imageUrl: imageUrl
        )
         
        do {
            _ = try db.collection("posts").addDocument(from: newLog)
            completion(true)
        } catch {
            print("Error saving log: \(error)")
            completion(false)
        }
    }
    
    // MARK: - ログアウト処理
    func signOut(userManager: UserManager, profileViewModel: ProfileViewModel) {
        do {
            try self.auth.signOut()
             
            Task { @MainActor in
                userManager.currentUser = nil
                profileViewModel.reset()
            }
             
        } catch {
            print("ログアウトエラー: \(error.localizedDescription)")
        }
    }
}
