//
//  ContentView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/25.
//

// このファイルは、投稿一覧を表示し、新規投稿や編集・削除を行うためのメイン画面(View)を定義します

// MARK: - View 本体

import SwiftUI

struct ContentView: View {
    @State var viewModel = ViewModel()
    @State var profileViewModel = ProfileViewModel()
    @State var matchingViewModel = MatchingViewModel()
    
    // 配色の定義
    let backgroundColor = Color(red: 0.98, green: 0.96, blue: 0.94)
    let barColor = Color(red: 0.23, green: 0.23, blue: 0.23)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- 1. 自作の細い上部ナビゲーションバー ---
                ZStack {
                    barColor.ignoresSafeArea(edges: .top)
                    Text("アプリ名")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                }
                .frame(height: 40) // 高さを自由に調整
                
                // --- 2. メインコンテンツエリア ---
                ZStack {
                    backgroundColor.ignoresSafeArea()
                    
                    // 現在のタブに応じてViewを出し分ける
                    Group {
                        switch viewModel.selectedTab {
                        case 0: HomeView(viewModel: viewModel, profileViewModel: profileViewModel)
                        case 1: SearchView(viewModel: viewModel)
                        case 2: SelectShopView().environment(viewModel)
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
        }
    }
}

// MARK: - 自作タブバーのパーツ
extension ContentView {
    var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(image: "house", fillImage: "house.fill", label: "ホーム", tag: 0)
            tabButton(image: "magnifyingglass", fillImage: "magnifyingglass", label: "見つける", tag: 1)
            tabButton(image: "plus.app", fillImage: "plus.app.fill", label: "投稿", tag: 2)
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
