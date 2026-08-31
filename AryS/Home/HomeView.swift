//
//  HomeView.swift
//  snsmvvm
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @Environment(AuthManager.self) var authManager
    @Environment(UserManager.self) var userManager
    @Environment(ProfileViewModel.self) var profileViewModel
    @State var homeViewModel = HomeViewModel()
    @State var timeLineViewModel = TimeLineViewModel()
    
    var body: some View {
        TabView(selection: $homeViewModel.selectedTab) {
            // --- 0: ホーム（タイムライン）タブ ---
            NavigationStack {
                TimeLineView(timeLineViewModel: timeLineViewModel)
                    .modifier(
                        ProfileToolbarModifier(
                            profileViewModel: profileViewModel,
                            authManager: authManager))
            }
            .tabItem {
                Label("ホーム", systemImage: "house")
            }
            .tag(0)
             
            // --- 1: 投稿するタブ ---
            NavigationStack {
                CoffeeRecordView(
                    onDismiss: {
                        homeViewModel.selectedTab = 0
                    },
                    onCompleted: {
                        homeViewModel.selectedTab = 0
                    }
                )
                .toolbar(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .tabBar)
            }
            .tabItem {
                Label("投稿する", systemImage: "plus")
            }
            .tag(1)
             
            // --- 2: プロフィールタブ ---
            NavigationStack {
                ProfileView()
                    .modifier(
                        ProfileToolbarModifier(
                            profileViewModel: profileViewModel,
                            authManager: authManager))
            }
            .tabItem {
                Label("プロフィール", systemImage: "person.circle")
            }
            .tag(2)
        }
        .tint(.primary)
        .task {
            if let uid = Auth.auth().currentUser?.uid {
                await userManager.fetchCurrentUser(uid: uid)
            }
        }
    }
}

// MARK: - プレビュー用ダミー＆モック環境
#Preview("ダークモード") {
    HomeView()
        .environment(AuthManager())
        .environment(UserManager())
        .environment(ProfileViewModel())
        .preferredColorScheme(.dark)
}

#Preview("ライトモード") {
    HomeView()
        .environment(AuthManager())
        .environment(UserManager())
        .environment(ProfileViewModel())
        .preferredColorScheme(.light)
}
