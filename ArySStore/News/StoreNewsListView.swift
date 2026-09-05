//
//  StoreNewsListView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreNewsListView: View {
    @State private var viewModel = StoreNewsListViewModel()
    @State private var isShowingAddView = false
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            // NEWS一覧リスト
            List {
                ForEach(viewModel.newsList) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(item.date)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Text(item.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(Color.black.opacity(0.2))
                }
                .onDelete { indexSet in
                    viewModel.deleteNews(at: indexSet)
                }
            }
            .scrollContentBackground(.hidden)
            
            // 右下の丸い＋ボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        isShowingAddView = true
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
        .fullScreenCover(isPresented: $isShowingAddView) {
            StoreNewsAddView()
        }
    }
}

// MARK: - プレビュー
#Preview {
    StoreNewsListView()
        .preferredColorScheme(.dark)
}
