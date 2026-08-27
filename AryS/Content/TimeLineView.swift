//
//  TimeLineView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/18.
//

import SwiftUI

struct TimeLineView: View {
    @State var timeLineViewModel: TimeLineViewModel
    @Environment(ProfileViewModel.self) var profileViewModel
     
    @State private var currentLogId: String?
    @State private var editingLog: Log?
    @State private var isShowingEditSheet = false
     
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                 
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(timeLineViewModel.logs) { log in
                            AsyncPostRow(
                                post: log,
                                fetchUser: { userId in
                                    try await timeLineViewModel.fetchUser(userId: userId)
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
                            .containerRelativeFrame(.vertical) { length, _ in length }
                            .id(log.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $currentLogId)
                .scrollContentBackground(.hidden)
            }
            .sensoryFeedback(.selection, trigger: currentLogId)
            .sheet(item: $editingLog) { logToEdit in
                if let index = timeLineViewModel.logs.firstIndex(where: { $0.id == logToEdit.id }) {
                    PostEditView(post: $timeLineViewModel.logs[index]) { updatedLog in
                        // 💡 非同期コンテキストやアニメーションの競合を防ぎ、メインスレッドで確実に即時反映させる
                        Task { @MainActor in
                            timeLineViewModel.updateLocalLog(updatedLog)
                        }
                    }
                }
            }
        }
    }
}

