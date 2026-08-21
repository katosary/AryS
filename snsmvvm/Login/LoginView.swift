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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // --- タイトル ---
                    Text("ログイン")
                        .font(.title2)
                        .bold()
                        .padding(.top, 20)
                    
                    // --- 外枠のカード ---
                    VStack(spacing: 0) {
                        
                        // メアド・パスワード入力セクション
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
                                
                                // 💡 第一引数にプレースホルダーの文字列を追加します
                                SecureField("半角英字と数字を含めた8文字以上", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(isLoading)
                            }
                            
                            // エラーメッセージ表示
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // 実行ボタン（ログイン処理）
                            Button {
                                isLoading = true
                                errorMessage = ""
                                
                                authManager.signIn(email: email, password: password) { error in
                                    DispatchQueue.main.async {
                                        isLoading = false
                                        if let error = error {
                                            self.errorMessage = error
                                        }
                                    }
                                }
                            } label: {
                                Group {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.primary)
                                    } else {
                                        Text("ログイン")
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
                        
                        // 3. 下部のアカウント切り替え導線（NavigationLinkで完全に別のビューへ遷移）
                        NavigationLink {
                            SignUpView(authManager: authManager)
                        } label: {
                            Text("会員登録はこちら")
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
