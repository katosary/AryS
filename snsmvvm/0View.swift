//
//  ContentView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/25.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = ViewModel()
    @Environment(ProfileViewModel.self) var profileViewModel
    @State var matchingViewModel = MatchingViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    // 💡 メニューの開閉状態を管理するStateを追加
    @State private var isMenuPresented = false
    @State private var isShowingSelectShop = false
    
    // 配色の定義
    let backgroundColor = Color(.white)//red: 0.98, green: 0.96, blue: 0.94
    let barColor = Color(red: 0.23, green: 0.23, blue: 0.23)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- 1. 自作の上部ナビゲーションバー ---
                ZStack {
                    barColor.ignoresSafeArea(edges: .top)
                    
                    // アプリ名
                    Text("アプリ名")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                    
                    // 💡 左右のボタンを配置するHStack
                    HStack {
                        // 【追加】左側のメニューボタン
                        Button {
                            isMenuPresented = true // タップでメニューを開く
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.body)
                                .fontWeight(.bold)
                                .padding(8)
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 12) // 左側に少し余白を作る

                        Spacer() // これでプラスボタンは左、メニューボタンは右に押し分けられます
                        
                        // 右側の投稿ボタン
                        Button {
                            // プラスボタンが押された時のアクションをここに書く
                            isShowingSelectShop = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.body)
                                .fontWeight(.bold)
                                .padding(8)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 12) // 右側に少し余白を作る
                    }
                }
                .frame(height: 40) // 高さを自由に調整
                
                // --- 2. メインコンテンツエリア ---
                ZStack {
                    backgroundColor.ignoresSafeArea()
                    
                    // 現在のタブに応じてViewを出し分ける
                    Group {
                        switch viewModel.selectedTab {
                        case 0: HomeView(viewModel: viewModel, profileViewModel: profileViewModel)
                        case 1: SearchView(viewModel: viewModel,profileViewModel: profileViewModel)
                        case 2: TalkView()
                        case 3: MatchingView(matchingViewModel: matchingViewModel)
                        case 4: ProfileView(viewModel: viewModel, profileViewModel: profileViewModel)
                        default: EmptyView()
                        }
                    }
                }
                
                // --- 3. 自作の細い下部タブバー ---
                customTabBar
            }
            .navigationBarHidden(true) // 標準バーを隠す
            // 💡 メニューシートの表示ロジックをここへ引っ越し
            .sheet(isPresented: $isMenuPresented) {
                ProfileMenuView(profileViewModel: profileViewModel)
                    .environmentObject(authManager)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            // 💡 プロフィール編集シートも、ProfileMenuView内のボタンから連動して開くためここに配置
            .sheet(isPresented: .init(
                get: { profileViewModel.isProfileEditSheet },
                set: { profileViewModel.isProfileEditSheet = $0 }
            )){
                ProfileEditView(profileViewModel: self.profileViewModel)
                    .onAppear {
                        profileViewModel.logs = viewModel.logs
                    }
            }
            .sheet(isPresented: $isShowingSelectShop) {
                // SelectShopView は遷移先を持つため NavigationStack で囲むのが一般的です
                NavigationStack {
                    SelectShopView()
                }
            }
        }
    }
}

// MARK: - 自作タブバーのパーツ
extension ContentView {
    var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(image: "house", fillImage: "house.fill", label: "ホーム", tag: 0)
            tabButton(image: "magnifyingglass", fillImage: "magnifyingglass", label: "見つける", tag: 1)
            tabButton(image: "message", fillImage: "message.fill", label: "トーク", tag: 2)
            tabButton(image: "person.3", fillImage: "person.3.fill", label: "マッチ", tag: 3)
            tabButton(image: "person.circle", fillImage: "person.circle.fill", label: "プロフィール", tag: 4)
        }
        .padding(.top, 8)
        .padding(.bottom, 4) // 必要に応じて調整
        .background(barColor.ignoresSafeArea(edges: .bottom))
    }
    
    // 各ボタンのデザイン
    func tabButton(image: String, fillImage: String, label: String, tag: Int) -> some View {
        let isSelected = viewModel.selectedTab == tag
        
        return Button {
            viewModel.selectedTab = tag
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? fillImage : image)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
