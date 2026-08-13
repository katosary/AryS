//
//  EmptyRatingView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/10.
//

import SwiftUI

struct EmptyhRatingView: View {
    let rating: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in Image(systemName: "star").foregroundColor(.white) }
            }
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in Image(systemName: "star.fill").foregroundColor(.white) }
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
