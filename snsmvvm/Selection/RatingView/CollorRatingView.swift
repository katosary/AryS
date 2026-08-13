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
        HStack(spacing: 0) {
            Text("◀ 弱い")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
            
            Spacer()
            
            // --- 小数対応の星描画エリア ---
            ZStack(alignment: .leading) {
                // 下地：グレーの星（5つ）
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(.systemGray4))
                    }
                }
                
                // 上書き：オレンジの星（5つ）を、ratingの数値分だけマスクして表示
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    }
                }
                .mask(
                    GeometryReader { geometry in
                        Rectangle()
                        // rating が 2.5 なら、2.5 / 5.0 = 50% の横幅だけオレンジにする
                            .frame(width: geometry.size.width * CGFloat(rating / Double(maxRating)))
                    }
                )
            }
            
            Spacer()
            
            Text("強い ▶")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

