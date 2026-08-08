//
//  TimeLineView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/18.
//

import SwiftUI

struct TimeLineView: View {
    @State private var selectedSelection = 0
    @State private var timeLineViewModel = TimeLineViewModel()
    @Environment(ProfileViewModel.self) var profileViewModel
    
    var body: some View {
        NavigationStack{
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(timeLineViewModel.logs) { log in
                        AsyncPostRow(
                            post: log,
                            fetchUser: { userId in
                                try await timeLineViewModel.fetchUser(userId: userId)
                            },
                            content: { author in
                                let isMyPost = log.userId == profileViewModel.user.id
                                let displayAuthor = isMyPost ? profileViewModel.user : author
                                
                                return CoffeeLogView(
                                    log: log,
                                    author: displayAuthor,
                                    authorName: displayAuthor.userName,
                                    coffeeLogViewModel: CoffeeLogViewModel(),
                                    isEditable: isMyPost,
                                    onDelete: {
                                        timeLineViewModel.deleteLog(targetPost: log)
                                    },
                                    onEdit: {
                                    }
                                )
                            }
                        )
                        .id(log.id)
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                await timeLineViewModel.fetchLogs()
            }
            .background(Color(.systemBackground))
        }
        .onAppear {
            Task {
                await timeLineViewModel.fetchLogs()
            }
        }
    }
}
