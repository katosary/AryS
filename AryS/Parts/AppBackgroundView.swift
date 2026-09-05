//
//  AppBackgroundView.swift
//  AryS
//
//  Created by katoso on 2026/08/30.
//

import SwiftUI

struct AppBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    let barColor: Color
     
    init(barColor: Color = Color(red: 89/255, green: 61/255, blue: 43/255)) {
        self.barColor = barColor
    }
     
    var body: some View {
        LinearGradient(
            colors: [
                barColor, // 上部はしっかりとした茶色
                colorScheme == .dark ? barColor.opacity(0.3) : barColor.opacity(0.15), // 中間
                colorScheme == .dark ? Color.black : Color(red: 248/255, green: 245/255, blue: 240/255) // ライト時はアイボリー系にする
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
