//
//  TimeLineToolbarModifier.swift
//  AryS
//
//  Created by katoso on 2026/08/30.
//

import SwiftUI

struct TimeLineToolbarModifier: ViewModifier {
    var timeLineViewModel: TimeLineViewModel
    var authManager: AuthManager
    
    // 💡 絞り込み画面（SearchTipsView）の表示状態を管理するフラグ
    @State private var isShowingSearchTips = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // TODO: 左側のボタンのアクションをここに実装
                    }) {
                        Image(systemName: "square.grid.2x2")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
                 
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .foregroundColor(.primary)
                        .scaledToFit()
                        .frame(height: 44)
                }
                 
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // 💡 右ボタンタップでシートを表示
                        isShowingSearchTips = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            // 💡 画面下から SearchTipsView をシート表示（NavigationStackで囲むとタイトルの「完了」ボタンが綺麗に配置されます）
            .sheet(isPresented: $isShowingSearchTips) {
                NavigationStack {
                    SearchFilterView(title: "絞り込み")
                }
            }
    }
}
