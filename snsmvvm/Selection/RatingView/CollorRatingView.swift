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
            
            // 星描画エリア
            ZStack(alignment: .leading) {
                // 下地：グレーの星
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(.systemGray4))
                    }
                }
                
                // 上書き：オレンジの星
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
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
