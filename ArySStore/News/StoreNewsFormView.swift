//
//  StoreNewsFormView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreNewsFormView: View {
    @State var viewModel: StoreNewsFormViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("店舗NEWS配信プレビュー・編集")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                // --- プレビュー兼入力カード ---
                VStack(alignment: .leading, spacing: 16) {
                    
                    // 1. 大きく題名 ＆ 投稿された日付・時間
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top) {
                            TextField("（ここにタイトルを入力）", text: $viewModel.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("2026/09/03 12:00")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        // 2. 少し小さくサブタイトル
                        TextField("（サブタイトルがあればここに入力）", text: $viewModel.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // 3. 写真（縦４：横３の比率）
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                            .aspectRatio(3/4, contentMode: .fit)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                            Text("写真をタップして選択")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 4. 本文（背景透明のTextEditor）
                    VStack(alignment: .leading, spacing: 4) {
                        Text("本文")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextEditor(text: $viewModel.bodyText)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .foregroundColor(.white)
                    }
                    
                    // 5. リンクを貼るテキストボックス
                    VStack(alignment: .leading, spacing: 4) {
                        Text("関連リンク (URL)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                                .foregroundColor(.yellow)
                            
                            TextField("https://...", text: $viewModel.linkUrl)
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                                .font(.subheadline)
                                .foregroundColor(.yellow)
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
}
