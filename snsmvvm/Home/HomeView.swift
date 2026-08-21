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
    
    let barColor = Color(red: 74 / 255, green: 55 / 255, blue: 43 / 255)
    
    var body: some View {
        TabView(selection: $homeViewModel.selectedTab) {
            // --- 0: ホーム（タイムライン）タブ ---
            NavigationStack {
                TimeLineView()
                    .modifier(DarkToolbarModifier(profileViewModel: profileViewModel, authManager: authManager))
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
                    .modifier(DarkToolbarModifier(profileViewModel: profileViewModel, authManager: authManager))
            }
            .tabItem {
                Label("プロフィール", systemImage: "person.circle")
            }
            .tag(2)
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
        // 💡 プロフィール編集シートの管理
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
    // 💡 修正：はっきりした茶色（例: #5C4633 系の濃い茶色）
    let barColor = Color(red: 92/255, green: 70/255, blue: 51/255)
    
    var profileViewModel: ProfileViewModel
    var authManager: AuthManager

    func body(content: Content) -> some View {
        content
            .toolbar {
                // 💡 左上のハンバーガーメニューボタン
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        ProfileMenuView(profileViewModel: profileViewModel)
                            .environmentObject(authManager)
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                 
                // 💡 中央のロゴ部分（サイズを調整）
                ToolbarItem(placement: .principal) {
                    Image("logo") // アセットで登録した名前
                        .resizable()
                        .scaledToFit()
                        // 💡 修正：高さを大きくしてロゴを強調（例: 32 → 40 または 44）
                        .frame(height: 44)
                        // 💡 ヒント: アイコンが大きくはみ出る場合は、.clipped() を追加して調整します
                }
                 
                // 💡 右上のベルボタン
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
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
