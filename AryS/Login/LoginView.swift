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
    
    // 新規登録画面をフルスクリーンで表示するためのフラグ
    @State private var isShowingSignUp = false
    
    // ご指定の背景色（コーヒーブラウン）
    private let brandBackgroundColor = Color(red: 89/255, green: 61/255, blue: 43/255)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色を指定
                brandBackgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    // 全体の間隔を自然にするため、VStack全体の spacing を 24 に設定
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // --- トップのアイコン画像（サイズを大きく調整） ---
                        Image("IconEmpty")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160) // ご希望に合わせて大きめに調整
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
                            .padding(.top, 50)
                        
                        // --- タグライン ＆ タイトルセクション ---
                        VStack(spacing: 12) {
                            // 「[logo] にログイン」エリア
                            HStack(spacing: 6) {
                                Image("logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Text("にログイン")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            // 英語のタグライン
                            Text("share their likes, discover your likes.")
                                .font(.system(size: 15, weight: .bold, design: .serif))
                                .italic()
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                        
                        // --- 入力フィールドセクション ---
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // メールアドレス
                            VStack(alignment: .leading, spacing: 6) {
                                Text("メールアドレス")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                TextField("sample@email.com", text: $email)
                                    .textFieldStyle(CoffeeTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .disabled(isLoading)
                            }
                            
                            // パスワード
                            VStack(alignment: .leading, spacing: 6) {
                                Text("パスワード")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                SecureField("半角英数を含む6文字以上", text: $password)
                                    .textFieldStyle(CoffeeTextFieldStyle())
                                    .disabled(isLoading)
                            }
                        }
                        
                        // エラーメッセージ表示
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.yellow)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        // --- アクションボタン・リンク群 ---
                        VStack(spacing: 16) {
                            // ログインボタン
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
                                            .tint(brandBackgroundColor)
                                    } else {
                                        Text("続ける")
                                            .font(.headline)
                                            .bold()
                                    }
                                }
                                .foregroundColor(brandBackgroundColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(email.isEmpty || password.isEmpty ? Color.white.opacity(0.5) : Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                            }
                            .disabled(isLoading || email.isEmpty || password.isEmpty)
                            
                            // アカウント未登録ですか？ アカウントの作成
                            HStack(spacing: 4) {
                                Text("アカウントが未登録ですか？")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button {
                                    isShowingSignUp = true
                                } label: {
                                    Text("アカウントの作成")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.white)
                                        .underline()
                                }
                                .disabled(isLoading)
                            }
                        }
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(isPresented: $isShowingSignUp) {
            // LoginView 側が保持している authManager（または環境変数など）を渡す
            SignUpView(authManager: authManager)
        }
    }
}

// MARK: - ブラウン背景に合わせたテキストフィールドスタイル
struct CoffeeTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.black.opacity(0.2))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

#Preview {
    LoginView(authManager: AuthManager())
}
