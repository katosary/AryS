//
//  ProductListView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct ProductListView: View {
    let store: Store
    @State private var viewModel = ProductListViewModel()
    
    // 2列のレイアウト設定
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else if viewModel.products.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        Text("現在販売中の商品はありません")
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else {
                    // 一般ユーザー向け：2列グリッドの商品一覧
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.products) { product in
                                NavigationLink(destination: ProductPostView(product: product, store: store)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        // 商品画像
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.black.opacity(0.2))
                                            
                                            if let id = product.id, let uiImage = viewModel.productImages[id] {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                            } else if !product.imageUrl.isEmpty {
                                                ProgressView().tint(.white)
                                            } else {
                                                Image(systemName: "cup.and.saucer.fill")
                                                    .foregroundColor(.white.opacity(0.5))
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(10)
                                        .clipped()
                                        
                                        // 商品名
                                        Text(product.productName)
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.white)
                                            .lineLimit(2)
                                        
                                        // 価格 ＆ 焙煎度
                                        HStack(spacing: 8) {
                                            Text("¥\(product.price)")
                                                .font(.footnote)
                                                .bold()
                                                .foregroundColor(.yellow)
                                            
                                            Spacer()
                                            
                                            if !product.roastLevel.isEmpty {
                                                Text(product.roastLevel)
                                                    .font(.caption2)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.white.opacity(0.2))
                                                    .cornerRadius(4)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .navigationTitle("商品一覧")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let storeId = store.id {
                viewModel.fetchProducts(for: storeId)
            }
        }
    }
}
