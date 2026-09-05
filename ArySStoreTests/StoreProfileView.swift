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

// MARK: - 1ページ目：店舗プロフィールメイン画面
struct StoreProfileTopView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                // 1. 店舗の紹介写真（縦3・横4の比率 / 3:4）
                ZStack(alignment: .bottomLeading) {
                    Color.black.opacity(0.3)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 30))
                                Text("お店の紹介写真（焙煎機や焙煎風景など）")
                                    .font(.caption)
                            }
                            .foregroundColor(.white.opacity(0.7))
                        )
                    .aspectRatio(4/3, contentMode: .fit)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                
                // 2. 店舗名
                VStack(alignment: .leading, spacing: 4) {
                    Text("AryS Coffee Roasters")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("東京都・自家焙煎コーヒー専門店")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                
                // 3. 焙煎士情報（全体がボタンになっており詳細へ遷移）
                NavigationLink {
                    RoasterDetailView()
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .foregroundColor(.white.opacity(0.5))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("焙煎士：山田 太郎")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("「一杯のコーヒーに物語と感動を込めて、日々丁寧な焙煎を心がけています。」")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(16)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                
                // 4. お客様からのレビュー（最近のもの1つ）
                VStack(alignment: .leading, spacing: 8) {
                    Text("お客様からの声（最新）")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white.opacity(0.9))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("★★★★★")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Spacer()
                            Text("2026/09/01")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Text("「エチオピアの浅煎り豆を購入しました。香りが華やかで、冷めてからもフルーツのような甘みが続きとても美味しかったです！」")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 4) {
                    Image(systemName: "chevron.compact.down")
                        .font(.title2)
                    Text("スワイプして詳細を見る")
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 30)
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

// MARK: - 焙煎士のより詳しい情報が見られる画面
struct RoasterDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("焙煎士の詳細プロフィール")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Text("ここに焙煎士の経歴、コーヒーに対するこだわり、受賞歴などの詳細なストーリーを表示します。")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
        }
        .navigationTitle("焙煎士について")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - プレビュー
#Preview {
    StoreProfileView()
        .preferredColorScheme(.dark)
}
