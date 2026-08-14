//
//  SavedListView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/13.
//

// SavedPostsView.swift
import SwiftUI

struct SavedListView: View {
    @Environment(BookmarkManager.self) var bookmarkManager
    @State private var savedListViewModel = SavedListViewModel()
    @Environment(ProfileViewModel.self) var profileViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 1) {
                // SavedListView.swift の ForEach 部分を修正
                ForEach(savedListViewModel.savedLogs) { log in
                    NavigationLink(destination: SavedCoffeeLogFullscreenView(
                        savedListViewModel: savedListViewModel,
                        currentLogId: log.id
                    )) {
                        if let imageUrl = log.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipped()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        } else {
                            Color.gray.opacity(0.3)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
        .navigationTitle("保存済みの投稿")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // 画面が開いたときに初回フェッチ
            savedListViewModel.fetchSavedPosts(with: bookmarkManager.savedLogIds)
        }
        .onChange(of: bookmarkManager.savedLogIds) { _, newIds in
            // 保存状態（追加・削除）が変化した瞬間に再フェッチしてリストを更新
            savedListViewModel.fetchSavedPosts(with: newIds)
        }
    }
}
