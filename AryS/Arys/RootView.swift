//
//  RootView.swift
//  snsmvvm
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var userManager = UserManager()
    @State private var profileViewModel = ProfileViewModel()
    
    // 💡 ログイン中のみ存在する（ログアウトで破棄・リセットされる）ように配置
    @State private var bookmarkManager = BookmarkManager()
    
    // 💡 起動時のスプラッシュ画面を表示しているかどうかのフラグ
    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            // --- メインの切り替えコンテンツ ---
            Group {
                if let currentUser = Auth.auth().currentUser {
                    if !currentUser.isEmailVerified {
                        // 1. ログインはしているが、メール認証がまだの場合
                        EmailVerificationNoticeView(authManager: authManager)
                    } else {
                        // 2. ログインしていて、メール認証も完了している場合
                        HomeView()
                            .task {
                                await userManager.fetchCurrentUser(uid: currentUser.uid)
                            }
                            .task {
                                await profileViewModel.loadUserData()
                            }
                            // 💡 ログインしたタイミングでそのユーザー用の監視を確実にスタート
                            .task(id: currentUser.uid) {
                                bookmarkManager.startListening()
                            }
                    }
                } else {
                    // 3. ログインしていない場合
                    LoginView(authManager: authManager)
                }
            }
            .environmentObject(authManager)
            .environmentObject(userManager)
            .environment(profileViewModel)
            .environment(bookmarkManager)
            .zIndex(1) // メイン画面を奥に配置
             
            // --- 起動時のスプラッシュ画面 ---
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(2) // スプラッシュ画面を手前に配置
                    .onAppear {
                        // 2.0秒後にスプラッシュ画面をフェードアウトさせる
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeOut(duration: 0.6)) {
                                isShowingSplash = false
                            }
                        }
                    }
            }
        }
    }
}
