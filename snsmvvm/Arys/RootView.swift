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
    
    // BookmarkManagerはApp側から .environmentObject で流し込まれるため、
    // ここでは新規作成（@StateObject）せず、そのままアプリ全体の環境から伝搬されます。
    
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
            } else {
                LoginView(authManager: authManager)
            }
        }
        .environmentObject(authManager)
        .environmentObject(userManager)
        .environment(profileViewModel)
    }
}
