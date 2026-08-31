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
        ZStack {
            // 💡 1. 最背面に共通の背景ビューを配置
            AppBackgroundView()

            // タイムラインのスクロールコンテンツ
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
                        .background(Color.clear) // 💡 各行の背景もクリアにする
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $currentLogId)
            .scrollContentBackground(.hidden)
            .background(Color.clear) // 💡 ScrollView自体の背景を透明にする
        }
        .sensoryFeedback(.selection, trigger: currentLogId)
        .sheet(item: $editingLog) { logToEdit in
            if let index = timeLineViewModel.logs.firstIndex(where: { $0.id == logToEdit.id }) {
                PostEditView(post: $timeLineViewModel.logs[index]) { updatedLog in
                    Task { @MainActor in
                        timeLineViewModel.updateLocalLog(updatedLog)
                    }
                }
            }
        }
    }
}
