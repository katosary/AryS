//
//  EmailVerificationNoticeView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/25.
//

import SwiftUI
import FirebaseAuth

struct EmailVerificationNoticeView: View {
    @Environment(AuthManager.self) var authManager
    @Environment(\.scenePhase) private var scenePhase
    @State private var message = ""
    @State private var isLoading = false
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // 💡 最背面に共通の背景ビューを配置
            AppBackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.orange)
                 
                Text("メールアドレスの確認が必要です")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                 
                Text("ご登録いただいたメールアドレスに確認メールを送信しました。\nメール内のリンクをクリックして認証を完了させてください。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                 
                if !message.isEmpty {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                 
                // 確認メール再送信ボタン
                Button {
                    resendVerificationEmail()
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("確認メールを再送信する")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(isLoading)
                 
                Spacer()
                 
                // ログアウトボタン
                Button("ログアウトして別のアカウントでログイン") {
                    try? Auth.auth().signOut()
                    authManager.isLoggedIn = false
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            }
            .padding(.top, 40)
            .padding(.horizontal, 16)
        }
        .onAppear {
            startVerificationTimer()
        }
        .onDisappear {
            stopVerificationTimer()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
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
