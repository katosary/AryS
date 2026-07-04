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
    
    // 💡 ゲッターを作る: アクセスする瞬間に Auth.auth() を呼び出す
    private var auth: Auth {
        return Auth.auth()
    }
    
    init() {
        // 💡 init 内では Auth.auth() を直接呼ばず、セットアップ関数を呼ぶ
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        // 💡 self.auth を経由してアクセスする
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
    
    func registerAndLogin(email: String, password: String, completion: @escaping (String?) -> Void) {
        // 💡 すべて Auth.auth() を self.auth に置き換える
        self.auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error as NSError?, error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                // 登録済みならログインへ
                self?.signIn(email: email, password: password, completion: completion)
            } else if let error = error {
                completion(error.localizedDescription)
            } else if let user = authResult?.user {
                // Firestoreへの保存処理
                self?.saveUserToFirestore(uid: user.uid, email: email, completion: completion)
            }
        }
    }
    
    private func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        self.auth.signIn(withEmail: email, password: password) { _, error in
            completion(error?.localizedDescription)
        }
    }
    
    // AuthManager.swift 内の修正
    // 引数に投稿に必要なデータをすべて受け取るように変更します
    func saveLogToFirestore(
        shopName: String,
        countryName: String,
        farmName: String,
        roastLevel: String,
        aromarating: Int,
        aromaComment: String,
        bitternessrating1: Int,
        acidityrating1: Int,
        bodyrating1: Int,
        bitternessrating2: Int,
        acidityrating2: Int,
        bodyrating2: Int,
        tagX: CGFloat,
        tagY: CGFloat,
        imageUrl: String?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        // データベース参照の定義
        let db = Firestore.firestore()

        let newLog = Log(
            userId: uid,
            shopName: shopName,
            countryName: countryName,
            farmName: farmName,
            roastLevel: roastLevel,
            aromarating: aromarating,
            aromaComment: aromaComment,
            bitternessrating1: bitternessrating1,
            acidityrating1: acidityrating1,
            bodyrating1: bodyrating1,
            bitternessrating2: bitternessrating2,
            acidityrating2: acidityrating2,
            bodyrating2: bodyrating2,
            createdAt: Date(),
            tagX: tagX,
            tagY: tagY
        )
        
        // 省略されていた imageUrl の代入
        var logToSave = newLog
        logToSave.imageUrl = imageUrl
        
        do {
            _ = try db.collection("posts").addDocument(from: logToSave)
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func signOut() {
        do {
            try self.auth.signOut()
        } catch {
            print("ログアウトエラー: \(error.localizedDescription)")
        }
    }
    
    // AuthManager クラスの中に追加してください

    private func saveUserToFirestore(uid: String, email: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        
        // 保存するデータ（Userモデルに合わせて作成）
        let userData: [String: Any] = [
            "userNo": 0, // 必要に応じて調整
            "userName": "新規ユーザー",
            "selfIntroduction": "",
            "userAge": 0,
            "birthPlace": "",
            "favoriteCoffee": "",
            "probitter": 0,
            "proacidity": 0,
            "probody": 0,
            "proaroma": 0,
            "proflavor": ""
            // createdAt などが必要なら追加
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                completion(nil) // 成功
            }
        }
    }
}


