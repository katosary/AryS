//
//  HomeView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @Environment(ProfileViewModel.self) var profileViewModel
    @State var homeViewModel = HomeViewModel()
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userManager: UserManager
    
    @State private var isMenuPresented = false
    
    let barColor = Color(red: 0.23, green: 0.23, blue: 0.23)
    
    var body: some View {
        TabView(selection: $homeViewModel.selectedTab) {
            // --- 0: ホーム（タイムライン）タブ ---
            NavigationStack {
                TimeLineView()
                    .modifier(DarkToolbarModifier(isMenuPresented: $isMenuPresented, barColor: barColor))
            }
            .tabItem {
                Label("ホーム", systemImage: "house")
            }
            .tag(0)
             
            // --- 1: 投稿するタブ ---
            NavigationStack {
                CoffeeRecordView(
                    onDismiss: {
                        // 💡 ✖︎ボタンが押されたらホーム（タブ0）に戻す
                        homeViewModel.selectedTab = 0
                    },
                    onCompleted: {
                        // 💡 投稿完了したらホーム（タブ0）に戻す
                        homeViewModel.selectedTab = 0
                        // 必要に応じてタイムラインの再読み込み処理などをここに追加可能
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
                    .modifier(DarkToolbarModifier(isMenuPresented: $isMenuPresented, barColor: barColor))
            }
            .tabItem {
                Label("プロフィール", systemImage: "person.circle")
            }
            .tag(2)
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isMenuPresented) {
            ProfileMenuView(profileViewModel: profileViewModel)
                .environmentObject(authManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: .init(
            get: { profileViewModel.isProfileEditSheet },
            set: { profileViewModel.isProfileEditSheet = $0 }
        )) {
            if let currentUser = userManager.currentUser {
                ProfileEditView(user: currentUser)
                    .onAppear {
                        profileViewModel.logs = homeViewModel.logs
                    }
            } else {
                ProfileEditView(user: profileViewModel.user)
                    .onAppear {
                        profileViewModel.logs = homeViewModel.logs
                    }
            }
        }
        .task {
            if let uid = Auth.auth().currentUser?.uid {
                await userManager.fetchCurrentUser(uid: uid)
            }
        }
    }
}

// MARK: - 黒で統一された上部バー用のModifier
struct DarkToolbarModifier: ViewModifier {
    @Binding var isMenuPresented: Bool
    let barColor: Color

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isMenuPresented = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                 
                ToolbarItem(placement: .principal) {
                    Text("アプリ名")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                }
                 
                // 💡 右上のベルボタン
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            // 遷移先のお知らせビュー
                            NotificationView()
                        } label: {
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
            }
            .toolbarBackground(barColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
    }
}
