//
//  StoreNewsListView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreNewsListView: View {
    @State private var viewModel = StoreNewsListViewModel()
    
    // 2列のグリッド設定
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.newsList) { item in
                        // sheetからNavigationLinkに変更
                        NavigationLink {
                            StoreNewsEditView(
                                viewModel: StoreNewsEditViewModel(
                                    newsId: item.id ?? "",
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    bodyText: item.bodyText,
                                    linkUrl: item.linkUrl,
                                    imageUrl: item.imageUrl
                                )
                            )
                        } label: {
                            newsCardView(item: item)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                if let index = viewModel.newsList.firstIndex(where: { $0.id == item.id }) {
                                    viewModel.deleteNews(at: IndexSet(integer: index))
                                }
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(16)
            }
            
            // 右下の丸い＋ボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink {
                        StoreNewsAddView()
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
    }
    
    @ViewBuilder
    private func newsCardView(item: News) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // ニュース画像
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .aspectRatio(4/3, contentMode: .fit)
                
                if let id = item.id, let uiImage = viewModel.newsImages[id] {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else if !item.imageUrl.isEmpty {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // タイトル
            Text(item.title)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // 日付
            Text(item.date)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(10)
        .background(Color.black.opacity(0.25))
        .cornerRadius(12)
    }
}
