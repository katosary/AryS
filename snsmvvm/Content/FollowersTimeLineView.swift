//
//  FollowersTimeLineView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/18.
//

import SwiftUI

struct FollowersTimeLineView: View {
    @State private var followersTimeLineViewModel = FollowersTimeLineViewModel()
    @Environment(ProfileViewModel.self) var profileViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(followersTimeLineViewModel.logs) { log in
                    AsyncPostRow(
                        post: log,
                        fetchUser: { userId in
                            try await followersTimeLineViewModel.fetchUser(userId: userId)
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
                                    followersTimeLineViewModel.deleteLog(targetPost: log)
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
        .task {
            followersTimeLineViewModel.startListeningAllLogs()
        }
        .onDisappear {
            followersTimeLineViewModel.stopListening()
        }
    }
}
