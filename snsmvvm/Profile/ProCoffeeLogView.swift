//
//  ProCoffeeLogView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/22.
//

import SwiftUI

struct ProCoffeeLogView: View {
    var coffeeLogViewModel: CoffeeLogViewModel
    let totalWidth: CGFloat
    let totalHeight: CGFloat
    
    @Binding var isDetailShowing: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("ログ件数: \(coffeeLogViewModel.logs.count)")
            ForEach(coffeeLogViewModel.logs, id: \.id) { log in
                AsyncPostRow(
                    post: log,
                    // 💡 この fetchUser を追加する必要があります！
                    fetchUser: { userId in
                        try await coffeeLogViewModel.fetchUser(userId: userId)
                    },
                    content: { author in
                        CoffeeLogView(
                            log: log,
                            author: author,
                            authorName: author.userName,
                            isEditable: false,
                            onDelete: { coffeeLogViewModel.deleteLog(targetPost: log) },
                            onEdit: { }
                        )
                    }
                )
                .id(log.id)
            }
        }
    }
}


struct AsyncPostRow<Content: View>: View {
    let post: Log
    let fetchUser: (String) async throws -> User
    let content: (User) -> Content
    
    @State private var author: User?
    @State private var isFetching = false // 💡 二重取得防止

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

