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
    var animateTrigger: Bool = true
    
    private let beanSize: CGFloat = 36
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<maxRating, id: \.self) { index in
                ZStack {
                    // 1. 下地：未選択のコーヒー豆
                    Image("coffeeBean")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: beanSize, height: beanSize)
                        .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.2))
                    
                    // 2. 上書き：塗りつぶしのコーヒー豆
                    Image("coffeeBeanFill")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: beanSize, height: beanSize)
                        .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.2))
                        .mask(
                            GeometryReader { geometry in
                                let beanIndex = Double(index)
                                let targetFill = animateTrigger ? rating : 0
                                let fillPercentage = min(1.0, max(0.0, targetFill - beanIndex))
                                let maskWidth = geometry.size.width * CGFloat(fillPercentage)
                                
                                Rectangle()
                                    .frame(width: maskWidth)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        )
                }
                // 💡 ゆったり感を持たせた調整（duration: 0.9, delay: 0.2刻み）
                .animation(.easeInOut(duration: 0.9).delay(Double(index) * 0.2), value: animateTrigger)
                
                if index < maxRating - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
