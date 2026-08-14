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
    
    // false: ログイン画面, true: 新規登録画面
    @State private var isSignUpMode = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // --- タイトル ---
                    Text(isSignUpMode ? "新規会員登録" : "ログイン")
                        .font(.title2)
                        .bold()
                        .padding(.top, 20)
                    
                    // --- 外枠のカード ---
                    VStack(spacing: 0) {
                        
                        // 1. ソーシャルログインセクション
                        VStack(spacing: 16) {
                            HStack(spacing: 32) {
                                SocialLoginButton(imageName: "g.circle.fill", title: "Google", color: .red) {
                                    // TODO: Googleログイン処理
                                }
                                
                                SocialLoginButton(imageName: "xmark.circle.fill", title: "X", color: .primary) {
                                    // TODO: Xログイン処理
                                }
                                
                                SocialLoginButton(imageName: "apple.logo", title: "Apple", color: .primary) {
                                    // TODO: Appleログイン処理
                                }
                            }
                            .padding(.vertical, 24)
                        }
                        .disabled(isLoading)
                        
                        Divider()
                        
                        // 2. メアド・パスワード入力セクション
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // メールアドレス
                            VStack(alignment: .leading, spacing: 8) {
                                Text("メールアドレス")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.primary)
                                
                                TextField("mail@example.com", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .disabled(isLoading)
                            }
                            
                            // パスワード
                            VStack(alignment: .leading, spacing: 8) {
                                Text("パスワード")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.primary)
                                
                                SecureField("", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(isLoading)
                            }
                            
                            // ログイン時のみ：パスワードを忘れた方 / ログインでお困りの方
                            if !isSignUpMode {
                                HStack(spacing: 4) {
                                    Button("パスワードを忘れた方") {
                                        // TODO: パスワード再設定処理
                                    }
                                    Text("/")
                                    Button("ログインでお困りの方") {
                                        // TODO: ヘルプ処理
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 2)
                            }
                            
                            // エラーメッセージ表示
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // 実行ボタン
                            Button {
                                isLoading = true
                                errorMessage = ""
                                
                                if isSignUpMode {
                                    Auth.auth().createUser(withEmail: email, password: password) { result, error in
                                        DispatchQueue.main.async {
                                            isLoading = false
                                            if let error = error {
                                                self.errorMessage = error.localizedDescription
                                            } else {
                                                print("新規登録成功")
                                            }
                                        }
                                    }
                                } else {
                                    authManager.registerAndLogin(email: email, password: password) { error in
                                        DispatchQueue.main.async {
                                            isLoading = false
                                            if let error = error {
                                                self.errorMessage = error
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Group {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.primary)
                                    } else {
                                        Text(isSignUpMode ? "新規登録する" : "ログイン")
                                            .font(.headline)
                                    }
                                }
                                .foregroundColor(email.isEmpty || password.isEmpty ? .secondary : .black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(email.isEmpty || password.isEmpty ? Color(.systemGray6) : Color.white)
                                .cornerRadius(8)
                            }
                            .disabled(isLoading || email.isEmpty || password.isEmpty)
                            .padding(.top, 4)
                        }
                        .padding(24)
                        
                        Divider()
                        
                        // 3. 下部のアカウント切り替え導線
                        Button {
                            withAnimation {
                                isSignUpMode.toggle()
                                errorMessage = ""
                            }
                        } label: {
                            Text(isSignUpMode ? "すでにアカウントをお持ちの方はこちら（ログイン）" : "会員登録はこちら")
                                .font(.subheadline)
                                .underline()
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        }
                        .disabled(isLoading)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                }
            }
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

// MARK: - ソーシャルログイン用ボタンコンポーネント
struct SocialLoginButton: View {
    let imageName: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 1)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: imageName)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    LoginView(authManager: AuthManager())
}
