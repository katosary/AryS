//
//  ViewColor.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/21.
//

import SwiftUI

// 共通のグラデーション背景を適用するビュー拡張
extension View {
    func appBackgroundGradient() -> some View {
        self
            // ナビゲーションバーの背景を隠して、下のグラデーションを通す
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .background(
                LinearGradient(
                    colors: [Color("AccentColor"), Color.black], // 茶色系から黒へ
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}
