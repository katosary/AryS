//
//  HomeView.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/12.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedSelection = 0
    @State var viewModel: ViewModel
    @State var profileViewModel: ProfileViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            // 背景をシステム背景色にする
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            TabView(selection: $selectedSelection){
                FollowersView()
                    .tag(0)
                RecommendView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack(spacing: 20){
                Button(action: { selectedSelection = 0 }) {
                    Text("フォロー中")
                        .font(.system(size: 18, weight: .bold))
                        // 選択中は primary(黒/白)、未選択は secondary(グレー)
                        .foregroundStyle(selectedSelection == 0 ? Color.primary : Color.secondary)
                }
                
                Button(action: { selectedSelection = 1 }) {
                    Text("おすすめ")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(selectedSelection == 1 ? Color.primary : Color.secondary)
                }
            }
            .padding(.top)
        }
    }
}

// 各リストの表示用
struct FollowersView: View {
    var body: some View{
        Text("ここにフォロワーの投稿が表示される")
    }
}


struct RecommendView: View{
    var body: some View{
        Text("ここにアプリ全体でバズっている投稿が表示される")
    }
}

struct LogView: View {
    let log: Log
    var viewModel: ViewModel
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack {
            // ユーザー名・メニューなど
            HStack {
                Text(log.user.userNo == profileViewModel.user.userNo ? profileViewModel.user.userName : log.user.userName)
                    .foregroundColor(.primary) // 黒固定を解除
                    .frame(maxWidth: 150, alignment: .leading)
                
                Text(log.createdAt, style: .date)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: 150, alignment: .trailing)
                
                Menu {
                    Button { /* ... */ } label: { Label("編集", systemImage: "pencil") }
                    Button(role: .destructive) { viewModel.deleteLog(targetPost: log) } label: { Label("削除", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
            
            // ... (画像部分はそのまま) ...

            // テキスト部分
            VStack {
                // 各ラベルと値
                Group {
                    HStack { Text("Shop:").foregroundColor(.secondary); Text(log.shopName).foregroundColor(.primary) }
                    HStack { Text("County:").foregroundColor(.secondary); Text(log.countryName).foregroundColor(.primary) }
                    HStack { Text("Farmer:").foregroundColor(.secondary); Text(log.farmName).foregroundColor(.primary) }
                    HStack { Text("RoastLevel:").foregroundColor(.secondary); Text(log.roastLevel).foregroundColor(.primary) }
                }
                
                // 星評価部分も同様に
                HStack {
                    Text("BitternessRating:").foregroundColor(.secondary)
                    // ZStack内の星のImageにも .foregroundColor(.secondary) を入れるとより綺麗です
                }
            }
            .padding(15)
            // 文字色を削除（中の各テキストで指定済みのため）
        }
        .padding(20)
        // 背景をシステム背景色のグループ色にする（カードっぽくなる）
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
