//
//  EmailVerificationNoticeView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/25.
//

import SwiftUI
import FirebaseAuth

struct EmailVerificationNoticeView: View {
    @ObservedObject var authManager: AuthManager
    @State private var message = ""
    @State private var isLoading = false
    
    var body: some View {
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
            
            // 認証状態の更新チェックボタン
            Button {
                checkEmailVerification()
            } label: {
                Text("認証完了を確認する")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 24)
            
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
                // 引数が必要な場合は適宜修正してください（下記AuthManagerのシグネチャに合わせます）
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
    
    // 認証状態の再読み込みとチェック
    private func checkEmailVerification() {
        guard let user = Auth.auth().currentUser else { return }
        user.reload { error in
            if let error = error {
                message = "エラー: \(error.localizedDescription)"
                return
            }
            // ユーザー情報を再取得してトリガーを引く
            authManager.isLoggedIn = user.isEmailVerified
            if !user.isEmailVerified {
                message = "まだ認証が完了していません。"
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
