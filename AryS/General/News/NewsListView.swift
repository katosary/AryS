//
//  NewsListView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct NewsListView: View {
    @State private var viewModel = StoreNewsListViewModel()

    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            // NEWS一覧リスト（一般ユーザー向け：追加・削除ボタンなし）
            List {
                ForEach(viewModel.newsList) { item in
                    NavigationLink(destination: NewsPostView(news: item)) {
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
        NewsListView()
            .preferredColorScheme(.dark)
    }
}
