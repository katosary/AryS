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
    @EnvironmentObject var userManager: UserManager // 💡 追加：アプリ全体で共有しているUserManagerを受け取る
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack {
            List {
                // ProfileMenuView.swift の該当セクション部分
                Section {
                    // 1. プロフィール編集への導線
                    Button {
                        dismiss()
                        profileViewModel.isProfileEditSheet = true
                    } label: {
                        Label("プロフィールを編集", systemImage: "pencil")
                            .foregroundColor(.primary)
                    }
                     
                    // 💡 2. ボタンから NavigationLink に変更して保存リストへ遷移
                    NavigationLink {
                        SavedListView()
                    } label: {
                        Label("保存", systemImage: "bookmark.fill")
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
                    Button(role: .destructive) {
                        // 💡 AuthManagerのsignOutに、userManagerとprofileViewModelを渡す
                        authManager.signOut(userManager: userManager, profileViewModel: profileViewModel)
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
