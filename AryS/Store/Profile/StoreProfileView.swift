//
//  StoreProfileView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreProfileView: View {
    @State private var selectedPage: Int = 0
    @State private var selectedSubTab: Int = 0
      
    var body: some View {
        GeometryReader { outerGeometry in
            let totalWidth = outerGeometry.size.width
            let totalHeight = outerGeometry.size.height
             
            ZStack {
                Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()

                NavigationStack {
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
                                    ZStack {
                                        Color.clear
                                        Text("商品View（タブ0）")
                                            .foregroundColor(.white)
                                    }
                                    .tag(0)
                                    
                                    ZStack {
                                        Color.clear
                                        Text("ニュースビュー（タブ1）")
                                            .foregroundColor(.white)
                                    }
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
                                
                                // サブタブボタン（背景を黒色に変更）
                                HStack(spacing: 0) {
                                    SubTabButton(title: "商品", index: 0, selectedTab: $selectedSubTab)
                                    SubTabButton(title: "ニュース", index: 1, selectedTab: $selectedSubTab)
                                    SubTabButton(title: "お声", index: 2, selectedTab: $selectedSubTab)
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
                    .navigationTitle("店舗プロフィール")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(.hidden, for: .navigationBar)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                .background(Color.clear)
            }
        }
    }
}



// MARK: - サブタブ切り替え用のボタンコンポーネント
struct SubTabButton: View {
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                
                Rectangle()
                    .fill(selectedTab == index ? Color.white : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
    }
}



// MARK: - プレビュー
#Preview {
    StoreProfileView()
        .preferredColorScheme(.dark)
}
