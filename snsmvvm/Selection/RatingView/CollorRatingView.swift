//
//  CollorRatingView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/10.
//

import SwiftUI

struct CollorRatingView: View {
    let rating: Double
    let maxRating: Int
    
    var body: some View {
        // ラベルを削除し、コーヒー豆エリアを横幅いっぱいに広げる
        ZStack(alignment: .leading) {
            // 下地：未選択の時（枠線のコーヒー豆）
            // 💡 間隔を均等（spacedBy など、または Spacer を使う方法）にするため HStack で space を均等配置
            HStack(spacing: 0) {
                ForEach(0..<maxRating, id: \.self) { index in
                    Image("coffeeBean")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36) // さらに大きく（36×36）
                        .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.2))
                    if index < maxRating - 1 {
                        Spacer(minLength: 0) // 横幅いっぱいに自動で間隔を広げる
                    }
                }
            }
            
            // 上書き：選択された時（塗りつぶしのコーヒー豆）
            HStack(spacing: 0) {
                ForEach(0..<maxRating, id: \.self) { index in
                    Image("coffeeBeanFill")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36) // さらに大きく（36×36）
                        .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.2))
                    if index < maxRating - 1 {
                        Spacer(minLength: 0) // 横幅いっぱいに自動で間隔を広げる
                    }
                }
            }
            .mask(
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width * CGFloat(rating / Double(maxRating)))
                }
            )
        }
        .frame(maxWidth: .infinity) // 横幅いっぱいにする
    }
}

