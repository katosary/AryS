//
//  NewsPostView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct NewsPostView: View {
    let news: News

    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // --- プレビュー兼閲覧カード ---
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // 1. 大きく題名 ＆ 投稿された日付・時間
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Text(news.title)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text(news.date)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            // 2. 少し小さくサブタイトル
                            if !news.subtitle.isEmpty {
                                Text(news.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // 3. 写真（縦４：横３の比率：プレビュー表示）
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.3))
                                .aspectRatio(3/4, contentMode: .fit)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                Text("画像")
                                    .font(.caption)
                            }
                            .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        
                        // 4. 本文（読み取り専用）
                        VStack(alignment: .leading, spacing: 4) {
                            Text("本文")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(news.bodyText)
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // 5. 関連リンク（存在する場合のみ表示、またはリンクテキスト）
                        if !news.linkUrl.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("関連リンク")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "link")
                                        .foregroundColor(.yellow)
                                    
                                    Text(news.linkUrl)
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("NEWS詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NewsPostView(news: News(
            title: "秋限定ブレンド『Autumn Harvest』販売開始のお知らせ",
            subtitle: "深いコクと香ばしいナッツの余韻をお楽しみください。",
            date: "2026/09/01 10:00",
            bodyText: "本日より、秋季限定となる新ブレンドの提供を開始いたしました。",
            linkUrl: "https://example.com/autumn"
        ))
        .preferredColorScheme(.dark)
    }
}
