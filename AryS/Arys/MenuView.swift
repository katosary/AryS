//
//  ProfileMenuView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/22.
//

import SwiftUI
import FirebaseAuth

struct MenuView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthManager.self) var authManager
    @Environment(UserManager.self) var userManager
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(\.openURL) var openURL
        
    @State private var showLogoutConfirmation = false
        
    private let termsURL = URL(string: "https://sites.google.com/d/1hgwbPGg6Dz7nm3GNFxWw_1AsttJceEXx/p/1WAmRUDO552YbIq6X9fgbQnP0p8Bln8fR/edit")!
    private let privacyURL = URL(string: "https://sites.google.com/d/1yVKs4XMg78E3NSHHxruuzdQoAKV8XsyU/p/1QYho7F0qTFM6MpUOKbeMFJvDXcHYBViv/edit")!
    private let supportURL = URL(string: "https://sites.google.com/d/1LrjoNw1K1tIZ4GuBruEMUUgiV3oluk1T/p/1MyenidEXis5XbdkEYDNdjDEr0Pth_MTz/edit")!
        
    var body: some View {
        ZStack {
            // 背景ビューを最背面に配置
            AppBackgroundView()
                .ignoresSafeArea()
            
            NavigationStack {
                List {
                    Section {
                        NavigationLink {
                            SavedListView()
                        } label: {
                            Label("保存", systemImage: "bookmark.fill")
                                .foregroundColor(.primary)
                        }
                    }
                     
                    Section("設定とプライバシー") {
                        NavigationLink {
                            AccountSettingsView(authManager: authManager, userManager: userManager, profileViewModel: profileViewModel)
                        } label: {
                            Label("アカウント設定", systemImage: "person.crop.circle")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Section("サポートと規約") {
                        Button {
                            openURL(termsURL)
                        } label: {
                            Label("利用規約", systemImage: "doc.text")
                                .foregroundColor(.primary)
                        }

                        Button {
                            openURL(privacyURL)
                        } label: {
                            Label("プライバシーポリシー", systemImage: "hand.raised")
                                .foregroundColor(.primary)
                        }

                        Button {
                            openURL(supportURL)
                        } label: {
                            Label("サポート / お問い合わせ", systemImage: "questionmark.circle")
                                .foregroundColor(.primary)
                        }
                    }
                     
                    Section {
                        Button(role: .destructive) {
                            showLogoutConfirmation = true
                        } label: {
                            Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
                .scrollContentBackground(.hidden) // Listのデフォルト背景を非表示にしてカスタム背景を透けさせる
                .navigationTitle("設定")
                .navigationBarTitleDisplayMode(.inline)
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
}


// MARK: - アカウント設定画面（再認証＆アカウント削除機能）
struct AccountSettingsView: View {
    var authManager: AuthManager
    var userManager: UserManager
    var profileViewModel: ProfileViewModel
        
    @State private var showPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var deleteErrorMessage = ""
    @State private var isDeleting = false
        
    var body: some View {
        ZStack {
            // 背景ビューを配置
            AppBackgroundView()
                .ignoresSafeArea()
            
            List {
                Section(header: Text("アカウント管理"), footer: Text("アカウントを削除すると、投稿やプロフィールデータなどのすべての情報が削除され、復元できなくなります。セキュリティのため、削除時に再度パスワードの入力が必要です。")) {
                    Button(role: .destructive) {
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
                
                if !deleteErrorMessage.isEmpty {
                    Section {
                        Text(deleteErrorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .scrollContentBackground(.hidden) // Listのデフォルト背景を非表示にする
            .navigationTitle("アカウント設定")
            .navigationBarTitleDisplayMode(.inline)
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
    }
    
    private func executeReauthenticationAndDeletion() {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            deleteErrorMessage = "ユーザー情報が見つかりませんでした。再度ログインし直してください。"
            return
        }
        
        isDeleting = true
        deleteErrorMessage = ""
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: passwordInput)
        
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    isDeleting = false
                    deleteErrorMessage = "パスワードが間違っているか、再認証に失敗しました: \(error.localizedDescription)"
                }
                return
            }
            
            user.delete { deleteError in
                DispatchQueue.main.async {
                    isDeleting = false
                    if let deleteError = deleteError {
                        deleteErrorMessage = "アカウントの削除に失敗しました: \(deleteError.localizedDescription)"
                    } else {
                        authManager.signOut(userManager: userManager, profileViewModel: profileViewModel)
                    }
                }
            }
        }
    }
}
