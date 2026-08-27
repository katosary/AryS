//
//  AuthManager.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/07.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Observation

@Observable
class AuthManager {
    var isLoggedIn: Bool = false
    private var handle: AuthStateDidChangeListenerHandle?
    
    
    private var auth: Auth {
        return Auth.auth()
    }
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        handle = self.auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in 
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
            "dripper": "",
            "paperFilter": "",
            "kettle": "",
            "server": "",
            "scale": "",
            "mill": "",
            "grinder": "",
            "espressoMachine": "",
            "frenchPress": "",
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
    
    // MARK: - ログアウト処理
    func signOut(userManager: UserManager, profileViewModel: ProfileViewModel) {
        do {
            try self.auth.signOut()
             
            Task { @MainActor in
                userManager.currentUser = nil
                profileViewModel.reset()
                self.isLoggedIn = false
            }
             
        } catch {
            print("ログアウトエラー: \(error.localizedDescription)")
        }
    }
}
