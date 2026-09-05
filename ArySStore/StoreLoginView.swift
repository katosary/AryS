//
//  StoreLoginView.swift
//  snsmvvm
//
//  Created by katoso on 2026/09/02.
//

import SwiftUI
//import FirebaseAuth
//import FirebaseFirestore

struct StoreLoginView: View {
//    @Environment(AuthManager.self) var authManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    // 店舗用新規登録画面をフルスクリーンで表示するためのフラグ
    @State private var isShowingStoreSignUp = false
    
    // 店舗用の背景色（一般用と同じコーヒーブラウン、または少し色味を変えたい場合はここで調整可能）
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
                        
                        // --- トップのアイコン画像 ---
                        Image("IconEmpty")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
                            .padding(.top, 50)
                        
                        // --- タグライン ＆ タイトルセクション（店舗用） ---
                        VStack(spacing: 12) {
                            HStack(spacing: 6) {
                                Image("logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .foregroundColor(.white)
                                
                                Text("店舗用ログイン")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            // 店舗用のサブタイトル
                            Text("for store partners")
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
                                Text("店舗メールアドレス")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                TextField("store@email.com", text: $email)
                                    .textFieldStyle(StoreTextFieldStyle())
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
                                    .textFieldStyle(StoreTextFieldStyle())
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
                                
                                // TODO: 店舗用のログイン処理（必要に応じて店舗権限のチェックなどを追加）
//                                authManager.signIn(email: email, password: password) { error in
//                                    DispatchQueue.main.async {
//                                        isLoading = false
//                                        if let error = error {
//                                            self.errorMessage = error
//                                        }
//                                    }
//                                }
                            } label: {
                                Group {
                                    if isLoading {
                                        ProgressView()
                                            .tint(brandBackgroundColor)
                                    } else {
                                        Text("店舗管理画面へ進む")
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
                            
                            // 店舗アカウント未登録ですか？
                            HStack(spacing: 4) {
                                Text("店舗アカウントをお持ちではありませんか？")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button {
                                    isShowingStoreSignUp = true
                                } label: {
                                    Text("店舗登録")
                                        .font(.footnote)
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
        .fullScreenCover(isPresented: $isShowingStoreSignUp) {
            // TODO: 後ほど店舗用の新規登録画面（StoreSignUpViewなど）に差し替えます
            Text("店舗用新規登録画面（準備中）")
                .font(.title)
                .bold()
        }
    }
}

// MARK: - テキストフィールドスタイル
struct StoreTextFieldStyle: TextFieldStyle {
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
    StoreLoginView()
}
