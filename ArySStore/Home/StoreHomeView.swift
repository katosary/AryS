//
//  HomeView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/02.
//

import SwiftUI

struct StoreHomeView: View {
    @State private var viewModel = StoreHomeViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            // --- タブ 0: お客様の投稿 ---
            NavigationStack {
                StoreTimeLineView()
                    .navigationTitle("お客様の投稿")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("投稿", systemImage: "bubble.left.and.bubble.right")
            }
            .tag(0)
             
            // --- タブ 1: 商品編集 ---
            NavigationStack {
                StoreProductListView()
                    .navigationTitle("商品管理")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("商品", systemImage: "cup.and.saucer")
            }
            .tag(1)
             
            // --- タブ 2: NEWS ---
            NavigationStack {
                StoreNewsListView()
                    .navigationTitle("NEWS")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("NEWS", systemImage: "newspaper")
            }
            .tag(2)
             
            // --- タブ 3: アナリティクス ---
            NavigationStack {
                StoreAnalyticsView()
                    .navigationTitle("アナリティクス")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("分析", systemImage: "chart.bar")
            }
            .tag(3)
             
            // --- タブ 4: 店舗情報 ---
            NavigationStack {
                StoreProfileTabView()
                    .navigationTitle("店舗情報")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("店舗情報", systemImage: "storefront")
            }
            .tag(4)
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    StoreHomeView()
}
