//
//  StoreProductListView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/07.
//

import SwiftUI

struct StoreProductListView: View {
    @State private var viewModel = StoreProductListViewModel()
    
    // 2列のレイアウト設定
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 89/255, green: 61/255, blue: 43/255)
                    .ignoresSafeArea()
                
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else if viewModel.products.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "cup.and.saucer")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.5))
                            Text("登録された商品はありません")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(viewModel.products) { product in
                                    // 編集画面へのプッシュ遷移
                                    NavigationLink(destination: StoreProductEditView(product: product)) {
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
                                            
                                            // 商品名（ブレンド名または銘柄）
                                            Text(product.productName)
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundColor(.white)
                                                .lineLimit(2)
                                            
                                            // 価格
                                            Text("¥\(product.price)")
                                                .font(.footnote)
                                                .bold()
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                        }
                    }
                }
                
                // --- 右下のプラスボタン（新規登録画面へのプッシュ遷移） ---
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: StoreProductAddView()) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.brown)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("商品一覧")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchProducts()
            }
        }
    }
}
