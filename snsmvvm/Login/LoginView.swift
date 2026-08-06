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
    @ObservedObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    // 💡 ログインか新規登録かを切り替えるフラグ (false: ログイン, true: 新規登録)
    @State private var isSignUpMode = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // 💡 モード切替用のタイトルやピッカー
            Picker("モード", selection: $isSignUpMode) {
                Text("ログイン").tag(false)
                Text("新規登録").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 10)
            .disabled(isLoading)
            
            TextField("メールアドレス", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disabled(isLoading)
             
            SecureField("パスワード", text: $password)
                .textFieldStyle(.roundedBorder)
                .disabled(isLoading)
             
            Button(action: {
                isLoading = true
                errorMessage = ""
                
                if isSignUpMode {
                    // --- 新規登録の処理 ---
                    // AuthManagerに新規登録用メソッドがある場合はそちらを呼び出してください
                    Auth.auth().createUser(withEmail: email, password: password) { result, error in
                        DispatchQueue.main.async {
                            isLoading = false
                            if let error = error {
                                self.errorMessage = error.localizedDescription
                            } else {
                                // 登録成功時はauthManager側のセッション等も更新される想定
                                print("新規登録成功")
                            }
                        }
                    }
                } else {
                    // --- 既存のログイン処理 ---
                    authManager.registerAndLogin(email: email, password: password) { error in
                        DispatchQueue.main.async {
                            isLoading = false
                            if let error = error {
                                self.errorMessage = error
                            }
                        }
                    }
                }
            }) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(isSignUpMode ? "アカウント作成" : "ログイン")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty || password.isEmpty)
             
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}

#Preview {
    LoginView(authManager: AuthManager())
}
