//
//  SavedCoffeeLogFullscreenView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/14.
//

import SwiftUI

struct SavedCoffeeLogFullscreenView: View {
    var savedListViewModel: SavedListViewModel
    @State var currentLogId: String?
    @Environment(ProfileViewModel.self) var profileViewModel
    
    var body: some View {
        // 余計な NavigationLink やサムネイル表示コードをすべて削除しました
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(savedListViewModel.savedLogs) { log in
                    AsyncPostRow(
                        post: log,
                        fetchUser: { userId in
                            try await savedListViewModel.fetchUser(userId: userId)
                        }
                    ) { author in
                        CoffeeLogView(
                            log: log,
                            author: author,
                            authorName: author.userName,
                            isEditable: false
                        )
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .containerRelativeFrame(.vertical) { length, _ in length }
                    .id(log.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentLogId)
        .navigationTitle("保存済み")
        .navigationBarTitleDisplayMode(.inline)
    }
}
