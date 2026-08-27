//
//  ProfileFlavorDetailView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/23.
//

import SwiftUI

struct ProfileFlavorDetailView: View {
    @Environment(ProfileViewModel.self) var profileViewModel
    
    // レーティングが左からぐーと伸びるアニメーション用のトリガー状態
    @State private var animateRatings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // スクロールビューの中身全体を左寄せにする
                VStack(alignment: .leading, spacing: 0) {
                    // --- 下部：詳細エリア ---
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // --- 1. 味わい評価エリア ---
                        VStack(alignment: .leading, spacing: 18) {
                            VStack(spacing: 20) {
                                HStack {
                                    Text("好きな味わいのバランス")
                                        .font(.headline)
                                        .bold()
                                    Spacer()
                                }
                                
                                HStack {
                                    Spacer()
                                    Text("弱 ──────────── 強")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .padding(.trailing, 20)
                                }
                            }
                            
                            // 苦味
                            HStack(spacing: 16) {
                                Text("苦味")
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                CollorRatingView(
                                    rating: Double(profileViewModel.user.probitter),
                                    maxRating: 5,
                                    animateTrigger: animateRatings
                                )
                            }
                            .frame(height: 36)
                            
                            // 酸味
                            HStack(spacing: 16) {
                                Text("酸味")
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                CollorRatingView(
                                    rating: Double(profileViewModel.user.proacidity),
                                    maxRating: 5,
                                    animateTrigger: animateRatings
                                )
                            }
                            .frame(height: 36)
                            
                            // コク
                            HStack(spacing: 16) {
                                Text("コク")
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                CollorRatingView(
                                    rating: Double(profileViewModel.user.probody),
                                    maxRating: 5,
                                    animateTrigger: animateRatings
                                )
                            }
                            .frame(height: 36)
                            
                            // 甘味（prosweetness）
                            HStack(spacing: 16) {
                                Text("甘味")
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                CollorRatingView(
                                    rating: Double(profileViewModel.user.prosweetness),
                                    maxRating: 5,
                                    animateTrigger: animateRatings
                                )
                            }
                            .frame(height: 36)
                            
                            // フレーバー（proflavor）
                            HStack(spacing: 16) {
                                Text("フレーバー")
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                CollorRatingView(
                                    rating: Double(profileViewModel.user.proflavor),
                                    maxRating: 5,
                                    animateTrigger: animateRatings
                                )
                            }
                            .frame(height: 36)
                            
                            let tags = profileViewModel.user.flavorTags // (※Profile画面のほうは profileViewModel.user.flavorTags)
                            if !tags.isEmpty {
                                HStack(alignment: .top, spacing: 6) {
                                    Text("フレーバータグ") // 💡 「：」を削除
                                        .font(.body)
                                        .frame(width: 120, alignment: .leading) // 💡 幅を少し広げて1行に収める
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(tags, id: \.self) { tag in
                                            Text("#\(tag)")
                                                .font(.system(size: 12, weight: .semibold))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color.secondary.opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .onAppear {
                            if !animateRatings {
                                Task {
                                    try? await Task.sleep(nanoseconds: 200_000_000)
                                    // アニメーションの時間を少し長めにすることで、左から順に伸びていく軌跡が滑らかになります
                                    withAnimation(.easeInOut(duration: 2.0)) {
                                        animateRatings = true
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
