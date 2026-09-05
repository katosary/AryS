//
//  StoreTimeLineView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//


import SwiftUI

struct StoreTimeLineView: View {
    @State private var viewModel = StoreTimeLineViewModel()
    @State private var currentLogId: String?

    var body: some View {
        ZStack {
            // 背景色（店舗用アプリの共通背景や指定色）
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()

//            if viewModel.logs.isEmpty {
//                // 投稿がまだない場合の表示
//                VStack(spacing: 12) {
//                    Image(systemName: "bubble.left.and.bubble.right.fill")
//                        .font(.system(size: 40))
//                        .foregroundColor(.white.opacity(0.6))
//                    Text("まだお客様からの投稿はありません")
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.8))
//                }
//            } else {
//                // タイムラインのスクロールコンテンツ
//                ScrollView(.vertical, showsIndicators: false) {
//                    LazyVStack(spacing: 0) {
//                        ForEach(viewModel.logs) { log in
//                            AsyncPostRow(
//                                post: log,
//                                fetchUser: { userId in
//                                    try await viewModel.fetchUser(userId: userId)
//                                }
//                            ) { author in
//                                // 店舗用なので、必要に応じて編集ボタン等を省いたセル表示にカスタマイズ可能です
//                                PostCellView(
//                                    log: log,
//                                    author: author,
//                                    profileUser: nil, // 店舗側から見た場合の表示調整
//                                    onEdit: {}        // 店舗側では自分の店舗宛ての投稿を編集しないため空
//                                )
//                            }
//                            .frame(maxWidth: .infinity)
//                            .containerRelativeFrame(.vertical) { length, _ in length }
//                            .id(log.id)
//                            .background(Color.clear)
//                        }
//                    }
//                    .scrollTargetLayout()
//                }
//                .scrollTargetBehavior(.paging)
//                .scrollPosition(id: $currentLogId)
//                .scrollContentBackground(.hidden)
//                .background(Color.clear)
//            }
        }
        .sensoryFeedback(.selection, trigger: currentLogId)
    }
}
