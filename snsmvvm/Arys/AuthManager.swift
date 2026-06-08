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

    init() {
        // アプリ起動時やログイン状態が変化した時に常に監視する
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                // ログインしていれば true, ログアウトしていれば false
                self?.isLoggedIn = (user != nil)
            }
        }
    }
    
    // 不要になったら監視を解除（メモリリーク防止）
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func registerAndLogin(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
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
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            completion(error?.localizedDescription)
        }
    }

    private func saveUserToFirestore(uid: String, email: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData(["email": email, "createdAt": Date()]) { error in
            completion(error?.localizedDescription)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            // ※ addStateDidChangeListener が検知して自動的に
            // isLoggedIn が false になり、RootView がログイン画面へ切り替わります
        } catch {
            print("ログアウトエラー: \(error.localizedDescription)")
        }
    }

}

