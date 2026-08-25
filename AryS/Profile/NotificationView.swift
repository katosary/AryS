//
//  NotificationView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/13.
//

import SwiftUI

struct NotificationView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            // 中身が空の状態（EmptyView）
            EmptyView()
        }
        .navigationTitle("お知らせ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NotificationView()
    }
}
