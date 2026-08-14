//
//  RootView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/07.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var userManager = UserManager()
    @State private var profileViewModel = ProfileViewModel()
    
    // 💡 ログイン中のみ存在する（ログアウトで破棄・リセットされる）ように配置
    @State private var bookmarkManager = BookmarkManager()
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                HomeView()
                    .task {
                        if let uid = Auth.auth().currentUser?.uid {
                            await userManager.fetchCurrentUser(uid: uid)
                        }
                    }
                    .task {
                        await profileViewModel.loadUserData()
                    }
                    // 💡 ログインしたタイミングでそのユーザー用の監視を確実にスタート
                    .task(id: Auth.auth().currentUser?.uid) {
                        bookmarkManager.startListening()
                    }
            } else {
                LoginView(authManager: authManager)
            }
        }
        .environmentObject(authManager)
        .environmentObject(userManager)
        .environment(profileViewModel)
        .environment(bookmarkManager)
    }
}
