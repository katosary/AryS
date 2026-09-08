//
//  StoreProfileTabView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreProfileTabView: View {
    let store: Store
    @State private var selectedPage: Int = 0
    @State private var selectedSubTab: Int = 0
      
    var body: some View {
        GeometryReader { outerGeometry in
            let totalWidth = outerGeometry.size.width
            let totalHeight = outerGeometry.size.height
             
            ZStack {
                Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()

                // 外側の重複した NavigationStack を削除し、直接 ScrollView を配置する
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 1ページ目：店舗プロフィールトップ
                        StoreProfileTopView()
                            .frame(width: totalWidth, height: totalHeight)
                            .containerRelativeFrame(.vertical)
                            .background(Color.clear)
                         
                        // 2ページ目：タブボタンとコンテンツ
                        ZStack(alignment: .top) {
                            // サブタブごとの中身
                            TabView(selection: $selectedSubTab) {
                                ProductListView(store: store)
                                    .tag(0)
                                
                                NewsListView()
                                    .tag(1)
                                
                                ZStack {
                                    Color.clear
                                    Text("お客様からのお声ビュー（タブ2）")
                                        .foregroundColor(.white)
                                }
                                .tag(2)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .padding(.top, 50)
                             
                            // サブタブボタン
                            HStack(spacing: 0) {
                                ProfileTabButton(title: "商品", index: 0, selectedTab: $selectedSubTab)
                                ProfileTabButton(title: "ニュース", index: 1, selectedTab: $selectedSubTab)
                                ProfileTabButton(title: "お声", index: 2, selectedTab: $selectedSubTab)
                            }
                            .background(Color.black.opacity(0.4))
                            .frame(height: 50)
                        }
                        .frame(width: totalWidth, height: totalHeight)
                        .containerRelativeFrame(.vertical)
                        .background(Color.clear)
                    }
                }
                .scrollTargetBehavior(.paging)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .modifier(StoreProfileToolbarModifier(store: .constant(store)))
            }
        }
    }
}
