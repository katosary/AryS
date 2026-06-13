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
    @State private var viewModel = ViewModel()
    @State private var profileViewModel = ProfileViewModel()
    @State private var searchViewModel = SearchViewModel()
    
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
        .environmentObject(authManager)
        .environmentObject(userManager)
        .environment(viewModel)
        .environment(profileViewModel)
        .environment(searchViewModel)
    }
}
