//
//  ProfileMenuView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/22.
//

import SwiftUI
import FirebaseAuth

struct MenuView: View {
    @Environment(\.dismiss) var dismiss // 画面を閉じるための環境変数
    @Environment(AuthManager.self) var authManager
    @Environment(UserManager.self) var userManager
    @Environment(ProfileViewModel.self) var profileViewModel
    
    // アラートの表示管理用
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // 💡 1. プロフィール編集を NavigationLink（独立した別ビューへのプッシュ遷移）に変更
                    NavigationLink {
                        if let currentUser = userManager.currentUser {
                            ProfileEditView(user: currentUser)
                        } else {
                            ProfileEditView(user: profileViewModel.user)
                        }
                    } label: {
                        Label("プロフィールを編集", systemImage: "pencil")
                            .foregroundColor(.primary)
                    }
                     
                    // 2. 保存リストへ遷移
                    NavigationLink {
                        SavedListView()
                    } label: {
                        Label("保存", systemImage: "bookmark.fill")
                            .foregroundColor(.primary)
                    }
                }
                 
                Section("設定とプライバシー") {
                    // 💡 3. 「アカウント設定」画面へ遷移（中にアカウント削除を配置）
                    NavigationLink {
                        AccountSettingsView(authManager: authManager, userManager: userManager, profileViewModel: profileViewModel)
                    } label: {
                        Label("アカウント", systemImage: "person.crop.circle")
                    }
                     
                    // 💡 4. ラベルを「通知設定」に変更
                    NavigationLink {
                        Text("通知設定画面（開発中）")
                    } label: {
                        Label("通知設定", systemImage: "bell")
                    }
                }
                 
                Section {
                    // 💡 5. ログアウト（アイコン赤色 ＆ 最終確認アラート付き）
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("設定とアクティビティ")
            .navigationBarTitleDisplayMode(.inline)
            // ログアウト確認アラート
            .alert("ログアウト", isPresented: $showLogoutConfirmation) {
                Button("キャンセル", role: .cancel) {}
                Button("ログアウト", role: .destructive) {
                    authManager.signOut(userManager: userManager, profileViewModel: profileViewModel)
                    dismiss()
                }
            } message: {
                Text("本当にログアウトしますか？")
            }
        }
    }
}

// MARK: - アカウント設定画面（再認証＆アカウント削除機能）
struct AccountSettingsView: View {
    var authManager: AuthManager
    var userManager: UserManager
    var profileViewModel: ProfileViewModel
    
    // 状態管理用
    @State private var showPasswordPrompt = false // パスワード入力ポップアップの表示フラグ
    @State private var passwordInput = ""          // 入力されたパスワード
    @State private var deleteErrorMessage = ""     // エラーメッセージ
    @State private var isDeleting = false          // 処理中インジケータ
    
    var body: some View {
        List {
            Section(header: Text("アカウント管理"), footer: Text("アカウントを削除すると、投稿やプロフィールデータなどのすべての情報が削除され、復元できなくなります。セキュリティのため、削除時に再度パスワードの入力が必要です。")) {
                Button(role: .destructive) {
                    // 💡 ボタンを押したらパスワード入力用のポップアップを表示
                    passwordInput = ""
                    deleteErrorMessage = ""
                    showPasswordPrompt = true
                } label: {
                    HStack {
                        Spacer()
                        if isDeleting {
                            ProgressView()
                        } else {
                            Text("アカウントを削除")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(isDeleting)
            }
            
            // エラー表示
            if !deleteErrorMessage.isEmpty {
                Section {
                    Text(deleteErrorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("アカウント設定")
        .navigationBarTitleDisplayMode(.inline)
        // 💡 パスワード入力を促すアラート（TextField付き）
        .alert("本人確認", isPresented: $showPasswordPrompt) {
            SecureField("パスワードを入力", text: $passwordInput)
            Button("キャンセル", role: .cancel) {}
            Button("削除する", role: .destructive) {
                executeReauthenticationAndDeletion()
            }
        } message: {
            Text("アカウントを完全に削除するため、現在のパスワードを入力してください。")
        }
    }
    
    // 💡 再認証を行ってからアカウント削除を実行する関数
    private func executeReauthenticationAndDeletion() {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            deleteErrorMessage = "ユーザー情報が見つかりませんでした。再度ログインし直してください。"
            return
        }
        
        isDeleting = true
        deleteErrorMessage = ""
        
        // 1. 入力されたパスワードでクレデンシャルを作成
        let credential = EmailAuthProvider.credential(withEmail: email, password: passwordInput)
        
        // 2. 再認証（reauthenticate）を実行
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    isDeleting = false
                    deleteErrorMessage = "パスワードが間違っているか、再認証に失敗しました: \(error.localizedDescription)"
                }
                return
            }
            
            // 3. 再認証が成功したら、その直後にアカウント削除（user.delete）を実行
            user.delete { deleteError in
                DispatchQueue.main.async {
                    isDeleting = false
                    if let deleteError = deleteError {
                        deleteErrorMessage = "アカウントの削除に失敗しました: \(deleteError.localizedDescription)"
                    } else {
                        // 削除成功時はローカルの状態もクリアしてログアウト状態にする
                        authManager.signOut(userManager: userManager, profileViewModel: profileViewModel)
                    }
                }
            }
        }
    }
}
