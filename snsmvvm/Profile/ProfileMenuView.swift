//
//  ProfileMenuView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/22.
//

import SwiftUI

struct ProfileMenuView: View {
    @Environment(\.dismiss) var dismiss // 画面を閉じるための環境変数
    @EnvironmentObject var authManager: AuthManager
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // 1. プロフィール編集への導線
                    Button {
                        dismiss() // メニューを閉じてからシートを開く、または直接遷移
                        profileViewModel.isProfileEditSheet = true
                    } label: {
                        Label("プロフィールを編集", systemImage: "pencil")
                            .foregroundColor(.primary)
                    }
                    
                    // 2. ポストを投稿
                    Button {
                        dismiss()
                    } label: {
                        Label("お知らせ", systemImage: "list.clipboard")
                            .foregroundColor(.primary)
                    }
                }
                
                Section("設定とプライバシー") {
                    NavigationLink {
                        Text("アカウント設定画面（開発中）")
                    } label: {
                        Label("アカウント", systemImage: "person.crop.circle")
                    }
                    
                    NavigationLink {
                        Text("通知設定画面（開発中）")
                    } label: {
                        Label("通知", systemImage: "bell")
                    }
                }
                Section {
                    // ログアウトボタン
                    Button(role: .destructive) { // .destructiveで赤字にできます
                        authManager.signOut()
                        dismiss()
                    } label: {
                        Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("設定とアクティビティ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

