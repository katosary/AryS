//
//  RootView.swift
//  snsmvvm
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @State private var authManager = AuthManager()
    @State private var userManager = UserManager()
    @State private var bookmarkManager = BookmarkManager()
    @State private var profileViewModel = ProfileViewModel()
    @State private var isShowingSplash = true
    
    

    
    var body: some View {
        ZStack {
            Group {
                if let currentUser = Auth.auth().currentUser {
                    if !currentUser.isEmailVerified {
                        // 1. ログインはしているが、メール認証がまだの場合
                        EmailVerificationNoticeView()
                    } else {
                        // 2. ログインしていて、メール認証も完了している場合
                        HomeView()
                            .task {
                                await userManager.fetchCurrentUser(uid: currentUser.uid)
                            }
                            .task {
                                await profileViewModel.loadUserData()
                            }
                            .task(id: currentUser.uid) {
                                bookmarkManager.startListening()
                            }
                    }
                } else {
                    // 3. ログインしていない場合
                    LoginView()
                }
            }
            .environment(authManager)
            .environment(userManager)
            .environment(profileViewModel)
            .environment(bookmarkManager)
            .zIndex(1)
             
            // --- 起動時のスプラッシュ画面 ---
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(2)
                    .onAppear {
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
