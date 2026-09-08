//
//  PostCellView.swift
//  AryS
//
//  Created by katoso on 2026/08/27.
//

import SwiftUI

// 複雑さを解消するための切り出し用ビュー
struct PostCellView: View {
    let log: Log
    let author: User
    let profileUser: User
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
