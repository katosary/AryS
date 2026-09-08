//
//  StoreMenuView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/07.
//

import SwiftUI

struct StoreMenuView: View {
    @Environment(AuthManager.self) var authManager
    
    @State private var showLogoutConfirmation = false
    @State private var showPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var deleteErrorMessage = ""
    @State private var isDeleting = false
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255)
                .ignoresSafeArea()
            
            NavigationStack {
                List {
                    // ひとつのセクション内に「ログアウト」と「アカウント削除」をまとめる
                    Section("アカウント管理") {
                        // 1. ログアウトボタン（上）
                        Button(role: .destructive) {
                            showLogoutConfirmation = true
                        } label: {
                            Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                        
                        // 2. アカウント削除ボタン（下）
                        Button(role: .destructive) {
                            passwordInput = ""
                            deleteErrorMessage = ""
                            showPasswordPrompt = true
                        } label: {
                            HStack {
                                if isDeleting {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                } else {
                                    Label("アカウントを削除", systemImage: "trash")
                                        .foregroundColor(.red)
                                        .bold()
                                }
                            }
                        }
                        .disabled(isDeleting)
                    }
                    
                    // エラーメッセージがある場合のみ表示
                    if !deleteErrorMessage.isEmpty {
                        Section {
                            Text(deleteErrorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("メニュー")
                .navigationBarTitleDisplayMode(.inline)
                // ログアウト確認アラート
                .alert("ログアウト", isPresented: $showLogoutConfirmation) {
                    Button("キャンセル", role: .cancel) {}
                    Button("ログアウト", role: .destructive) {
                        authManager.signOut()
                    }
                } message: {
                    Text("本当にログアウトしますか？")
                }
                // アカウント削除（パスワード再認証）アラート
                .alert("本人確認", isPresented: $showPasswordPrompt) {
                    SecureField("パスワードを入力", text: $passwordInput)
                    Button("キャンセル", role: .cancel) {}
                    Button("削除する", role: .destructive) {
                        executeAccountDeletion()
                    }
                } message: {
                    Text("アカウントを完全に削除するため、現在のパスワードを入力してください。\n※店舗データもすべて削除されます。")
                }
            }
        }
    }
    
    // AuthManagerのdeleteAccountを利用したアカウント削除処理
    private func executeAccountDeletion() {
        isDeleting = true
        deleteErrorMessage = ""
        
        authManager.deleteAccount(password: passwordInput) { errorMessage in
            DispatchQueue.main.async {
                isDeleting = false
                if let errorMessage = errorMessage {
                    deleteErrorMessage = errorMessage
                }
            }
        }
    }
}
