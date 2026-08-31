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
    @Environment(AuthManager.self) var authManager
    
    @State var currentLogId: String?
    let initialLogId: String?
    
    @State private var editingLog: Log?
    @State private var isShowingEditSheet = false
    
    init(profileCoffeeLogViewModel: ProfileCoffeeLogViewModel, currentLogId: String?) {
        self.profileCoffeeLogViewModel = profileCoffeeLogViewModel
        _currentLogId = State(initialValue: currentLogId)
        self.initialLogId = currentLogId
    }
    
    var body: some View {
        ZStack {
            // 背景ビューを最背面に配置
            AppBackgroundView()
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(profileCoffeeLogViewModel.logs) { log in
                            AsyncPostRow(
                                post: log,
                                fetchUser: { userId in
                                    try await profileCoffeeLogViewModel.fetchUser(userId: userId)
                                }
                            ) { author in
                                PostCellView(
                                    log: log,
                                    author: author,
                                    profileUser: profileViewModel.user,
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
                .modifier(ProfileToolbarModifier(
                    profileViewModel: profileViewModel,
                    authManager: authManager
                ))
                .onAppear {
                    if let initialLogId {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            proxy.scrollTo(initialLogId, anchor: .top)
                        }
                    }
                }
            }
        }
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
