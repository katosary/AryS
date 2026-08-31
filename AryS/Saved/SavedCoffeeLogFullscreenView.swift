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
    
    let initialLogId: String?
    
    init(savedListViewModel: SavedListViewModel, currentLogId: String?) {
        self.savedListViewModel = savedListViewModel
        _currentLogId = State(initialValue: currentLogId)
        self.initialLogId = currentLogId
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView() // 背景ビューの適用
            
            ScrollViewReader { proxy in
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
                .scrollContentBackground(.hidden)
                .navigationTitle("保存済み")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    if let initialLogId {
                        // レイアウト確定後に確実にスクロールさせるため若干遅延・メインスレッドで実行
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            proxy.scrollTo(initialLogId, anchor: .top)
                        }
                    }
                }
            }
        }
    }
}
