//
//  ProductPostView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct ProductPostView: View {
    let product: Product
    let store: Store
    @State private var viewModel = ProductPostViewModel()

    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // --- 1. 商品画像表示 ---
                    ZStack(alignment: .bottomTrailing) {
                        if let uiImage = viewModel.productImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .clipped()
                        } else if viewModel.isLoadingImage {
                            ProgressView()
                                .tint(.white)
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                        } else {
                            fallbackImageView()
                        }
                    }
                    .aspectRatio(4/3, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // --- 2. 商品名 ---
                        VStack(alignment: .leading, spacing: 4) {
                            Text("商品名")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(product.productName)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            if !product.roastLevel.isEmpty {
                                Text("焙煎度: \(product.roastLevel)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.top, 2)
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // --- 3. 価格 ---
                        HStack(spacing: 8) {
                            Text("価格")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("¥\(product.price)")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.yellow)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // --- 4. 商品説明 ---
                        VStack(alignment: .leading, spacing: 6) {
                            Text("商品説明")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(product.description.isEmpty ? "商品説明がありません。" : product.description)
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
                        Text(store.storeName)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                            Text("\(store.prefecture)\(store.city)\(store.streetNumber)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // --- 6. 焙煎士情報 ---
                    NavigationLink {
                        RoasterDetailView(store: store)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white.opacity(0.5))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("焙煎士：\(store.roasterName.isEmpty ? "未設定" : store.roasterName)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(store.roasterBio.isEmpty ? "一杯のコーヒーに物語と感動を込めて..." : store.roasterBio)
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
                }
            }
        }
        .navigationTitle("商品詳細")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !product.imageUrl.isEmpty {
                viewModel.loadImage(from: product.imageUrl)
            }
        }
    }
    
    @ViewBuilder
    private func fallbackImageView() -> some View {
        ZStack {
            Color.black.opacity(0.3)
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
    }
}
