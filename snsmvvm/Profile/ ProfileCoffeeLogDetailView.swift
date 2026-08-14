//
//  ProfileCoffeeLogFullscreenView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/22.
//

import SwiftUI

struct ProfileCoffeeLogFullscreenView: View {
    @Bindable var profileCoffeeLogViewModel: ProfileCoffeeLogViewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    
    @State var currentLogId: String?
    
    @State private var editingLog: Log?
    @State private var isShowingEditSheet = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(profileCoffeeLogViewModel.logs) { log in
                        AsyncPostRow(
                            post: log,
                            fetchUser: { userId in
                                try await profileCoffeeLogViewModel.fetchUser(userId: userId)
                            }
                        ) { author in
                            // 💡 複雑さを解消するため、内部のビュー描画を切り出し
                            ProfilePostCellView(
                                log: log,
                                author: author,
                                profileUser: profileViewModel.user,
                                onDelete: {
                                    profileCoffeeLogViewModel.deleteLog(targetPost: log)
                                },
                                onEdit: {
                                    editingLog = log
                                    isShowingEditSheet = true
                                }
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .containerRelativeFrame(.vertical) { length, _ in
                            length
                        }
                        .id(log.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $currentLogId)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("アプリ名")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingEditSheet, onDismiss: { editingLog = nil }) {
            if let editingLog {
                PostEditView(post: Binding(
                    get: { editingLog },
                    set: { self.editingLog = $0 }
                ))
            }
        }
    }
}

// 💡 複雑なネストを避けるための切り出し用ビュー
private struct ProfilePostCellView: View {
    let log: Log
    let author: User
    let profileUser: User
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        let isMyPost = log.userId == profileUser.id
        let displayAuthor = isMyPost ? profileUser : author
        
        CoffeeLogView(
            log: log,
            author: displayAuthor,
            authorName: displayAuthor.userName,
            isEditable: isMyPost
        )
        .padding(.horizontal, 16)
    }
}

// 共通で使っている非同期ユーザー取得用パーツ
struct AsyncPostRow<Content: View>: View {
    let post: Log
    let fetchUser: (String) async throws -> User
    let content: (User) -> Content
    
    @State private var author: User?
    @State private var isFetching = false
    
    var body: some View {
        Group {
            if let author = author {
                content(author)
            } else {
                ProgressView().task {
                    guard !isFetching else { return }
                    isFetching = true
                    do {
                        self.author = try await fetchUser(post.userId)
                    } catch {
                        print("Error: \(error)")
                    }
                    isFetching = false
                }
            }
        }
    }
}
