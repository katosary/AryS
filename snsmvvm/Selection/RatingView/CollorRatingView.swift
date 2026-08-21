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
        HStack(spacing: 12) {
            // 左側のラベル
            Text("◀ 弱い")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
                .frame(width: 45, alignment: .leading)
            
            // コーヒー豆描画エリア
            ZStack(alignment: .leading) {
                // 下地：未選択の時（枠線のコーヒー豆）
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image("coffeeBean") // 💡 枠線用の画像名
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.2)) // 枠線の色（茶色）
                    }
                }
                
                // 上書き：選択された時（塗りつぶしのコーヒー豆）
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image("coffeeBeanFill") // 💡 塗りつぶし用の画像名
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.2)) // 塗りつぶしの色（茶色）
                    }
                }
                .mask(
                    GeometryReader { geometry in
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat(rating / Double(maxRating)))
                    }
                )
            }
            
            // 右側のラベル
            Text("強い ▶")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
                .frame(width: 45, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
