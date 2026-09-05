//
//  StoreProductListView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI


struct StoreProductListView: View {
    @State private var viewModel = StoreProductListViewModel()

    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            // 商品リスト
            List {
                ForEach(viewModel.products) { product in
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
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.black.opacity(0.2))
                }
                .onDelete { indexSet in
                    viewModel.deleteProduct(at: indexSet)
                }
            }
            .scrollContentBackground(.hidden)
            
            // 右下の丸い＋ボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        viewModel.isShowingAddView = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingAddView) {
            StoreProductAddView()
        }
    }
}

#Preview {
    StoreProductListView()
        .preferredColorScheme(.dark)
}
