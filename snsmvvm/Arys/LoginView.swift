//
//  LoginView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/03.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("メールアドレス", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("パスワード", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("新規登録してログイン") {
                registerAndLogin()
            }
            .buttonStyle(.borderedProminent)

            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
        }
        .padding()
    }

    func registerAndLogin() {
            // 1. まず新規登録を試みる
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error as NSError? {
                    // すでに登録済みエラーの場合、ログインを試みる
                    if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        self.signIn()
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    return
                }

                // 新規登録成功時の処理
                guard let user = authResult?.user else { return }
                saveUserToFirestore(uid: user.uid)
            }
        }

        func signIn() {
            // ログイン処理
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    errorMessage = "ログイン失敗: \(error.localizedDescription)"
                } else {
                    errorMessage = "ログイン成功！"
                }
            }
        }

        func saveUserToFirestore(uid: String) {
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "email": email,
                "createdAt": Date()
            ]) { error in
                if let error = error {
                    errorMessage = "Firestore登録失敗: \(error.localizedDescription)"
                } else {
                    errorMessage = "新規登録成功！"
                }
            }
        }
}


#Preview {
    LoginView()
}
