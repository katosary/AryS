//
//  RootView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/07.
//


import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                ContentView()
                    .task {
                        // ログイン成功時にUIDを取得してデータを読み込む
                        if let uid = Auth.auth().currentUser?.uid {
                            await userManager.fetchCurrentUser(uid: uid)
                        }
                    }
            } else {
                LoginView(authManager: authManager)
            }
        }
    }
}
