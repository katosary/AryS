
//
//  StoreEmailVerificationNoticeView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/06.
//

import SwiftUI
import FirebaseAuth

struct StoreEmailVerificationNoticeView: View {
    @Environment(AuthManager.self) var authManager
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var message = ""
    @State private var isLoading = false
    @State private var timer: Timer?
    
    // 店舗用アプリのブランドカラー
    private let brandBackgroundColor = Color(red: 89/255, green: 61/255, blue: 43/255)
    
    var body: some View {
        ZStack {
            brandBackgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "storefront.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Text("店舗オーナー様：メール確認が必要です")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("店舗アカウントの登録ありがとうございます。\nご登録いただいたメールアドレスに確認メールを送信しました。\n\nメール内のリンクをクリックして、店舗アカウントの認証を完了させてください。")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if !message.isEmpty {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                }
                
                // 確認メール再送信ボタン
                Button {
                    resendVerificationEmail()
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(brandBackgroundColor)
                    } else {
                        Text("確認メールを再送信する")
                            .font(.headline)
                            .bold()
                            .foregroundColor(brandBackgroundColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                }
                .disabled(isLoading)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // ログアウトボタン
                Button("ログイン画面に戻る（別のアカウント）") {
                    try? Auth.auth().signOut()
                    authManager.isLoggedIn = false
                }
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startVerificationTimer()
        }
        .onDisappear {
            stopVerificationTimer()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkEmailVerification()
            }
        }
    }
    
    // 定期的に認証状態をチェックするタイマーを開始
    private func startVerificationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            checkEmailVerification()
        }
    }
    
    // タイマーを停止
    private func stopVerificationTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 認証状態の再読み込みとチェック
    private func checkEmailVerification() {
        authManager.checkEmailVerification { isVerified in
            if isVerified {
                stopVerificationTimer()
            }
        }
    }
    
    // 確認メールの再送信
    private func resendVerificationEmail() {
        isLoading = true
        message = ""
        Auth.auth().currentUser?.sendEmailVerification { error in
            isLoading = false
            if let error = error {
                message = "送信失敗: \(error.localizedDescription)"
            } else {
                message = "確認メールを再送信しました！"
            }
        }
    }
}
