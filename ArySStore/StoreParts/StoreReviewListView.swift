//
//  StoreReviewListView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/05.
//

import SwiftUI

struct StoreReviewListView: View {
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    // ダミーデータで3件表示
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(alignment: .top, spacing: 12) {
                            // 1. 左側の写真
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                )
                            
                            // 2. 右側の情報（ユーザー名、Rating、口コミ内容）
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("コーヒー好き")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    // Rating（星マーク）
                                    HStack(spacing: 2) {
                                        ForEach(0..<5, id: \.self) { index in
                                            Image(systemName: index < 5 ? "star.fill" : "star")
                                                .font(.caption)
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                }
                                
                                // 口コミ内容（一文）
                                Text("香りがとても良く、酸味と苦味のバランスが最高でした！")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                        }
                        .padding(16)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
        }
    }
}

#Preview {
    StoreReviewListView()
        .preferredColorScheme(.dark)
}
