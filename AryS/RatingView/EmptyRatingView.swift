//
//  EmptyRatingView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/10.
//

import SwiftUI

struct EmptyRatingView: View {
    let rating: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            // 背景（未選択の状態：枠線や薄い豆など）
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in
                    Image("coffeeBean") // 💡 アセットにある線画のコーヒー豆画像名に変更してください
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
            }
            
            // 選択された状態（塗りつぶしの豆）
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in
                    Image("coffeeBeanFill") // 💡 塗りつぶし用のコーヒー豆画像名に変更してください（共通の場合は "coffeeBean" でもOK）
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
            }
            .mask(
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width * CGFloat(rating / 5.0))
                }
            )
        }
    }
}
