

//
//  ProductListView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct ProductListView: View {
    @State private var viewModel = StoreProductListViewModel()

    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            // 商品リスト（一般ユーザー向け：追加・削除ボタンなし）
            List {
                ForEach(viewModel.products) { product in
                    NavigationLink(destination: ProductPostView(product: product)) {
                        HStack(spacing: 12) {
                            // 商品サムネイル画像（仮）
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "cup.and.saucer.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 8) {
                                    Text(product.price)
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                    
                                    Text(product.roastLevel)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(4)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.black.opacity(0.2))
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    NavigationStack {
        ProductListView()
            .preferredColorScheme(.dark)
    }
}
