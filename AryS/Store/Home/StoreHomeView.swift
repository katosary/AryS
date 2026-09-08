//
//  HomeView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/02.
//

import SwiftUI

struct StoreHomeView: View {
    let store: Store
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
                StoreProfileTabView(store: store)
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
    StoreHomeView(
        store: Store(
            id: "sample_id",
            storeName: "AryS Coffee Roasters",
            postalCode: "1500002",
            prefecture: "東京都",
            city: "渋谷区渋谷",
            streetNumber: "1-2-3",
            buildingName: "",
            phoneNumber: "09012345678",
            email: "test@example.com",
            roasterName: "山田 太郎",
            roastingExperience: "5年",
            roasterBio: "豆の個性を最大限に引き出します",
            roastingMachine: "PROBAT",
            businessModel: "カフェ",
            estimatedRevenue: "〜100万円",
            desiredFeatures: "",
            futureExpectations: "",
            createdAt: Date()
        )
    )
}
