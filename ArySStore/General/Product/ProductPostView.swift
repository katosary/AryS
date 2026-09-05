//
//  ProductPostView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct ProductPostView: View {
    let product: Product
    @State private var currentIndex = 0
    // サンプル用として画像や説明文を保持
    let sampleImages: [String] = ["photo1", "photo2", "photo3"]
    let descriptionText = "ここに商品の詳しい説明やこだわりが入ります。厳選された豆を丁寧に焙煎しました。"

    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // --- 1. 画像スライダー（横4：縦3） ---
                    ZStack(alignment: .bottomTrailing) {
                        TabView(selection: $currentIndex) {
                            ForEach(0..<sampleImages.count, id: \.self) { index in
                                ZStack {
                                    Color.black.opacity(0.3)
                                    Image(systemName: "cup.and.saucer.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .aspectRatio(4/3, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        
                        // 現在地インジケーター（右下）
                        Text("\(currentIndex + 1) / \(sampleImages.count)")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // --- 2. 商品名（テキスト表示） ---
                        VStack(alignment: .leading, spacing: 4) {
                            Text("商品名")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(product.name)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // --- 3. 価格のみを表示（原価・手数料・利益は非表示） ---
                        HStack(spacing: 8) {
                            Text("価格")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text(product.price)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.yellow)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // --- 4. 商品説明（読み取り専用テキスト） ---
                        VStack(alignment: .leading, spacing: 6) {
                            Text("商品説明")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(descriptionText)
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(20)
                    
                    // --- 5. 店舗名 ---
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // --- 6. 焙煎士情報（全体がボタンになっており詳細へ遷移） ---
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // --- 7. ReviewView（商品に寄せられたレビューセクション） ---
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("カスタマーレビュー")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text("★ 4.8 (12件)")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 20)
                        
                        // レビューカードのサンプル
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(0..<2, id: \.self) { _ in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("コーヒー好きユーザー")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("2日前")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    
                                    Text("香りがとても豊かで、冷めてからも酸味が心地よく残る素晴らしいブレンドでした。リピート確定です！")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(14)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("商品詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProductPostView(product: Product(name: "秋限定ブレンド", price: "680円", roastLevel: "中煎り"))
            .preferredColorScheme(.dark)
    }
}
