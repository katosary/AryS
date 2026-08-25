//
//  OtherProfileFlavorDetailView.swift
//  snsmvvm
//

import SwiftUI

struct OtherProfileFlavorDetailView: View {
    @Environment(OtherProfileViewModel.self) private var viewModel
    
    @State private var animateRatings = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
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
                                rating: Double(viewModel.user.probitter),
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
                                rating: Double(viewModel.user.proacidity),
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
                                rating: Double(viewModel.user.probody),
                                maxRating: 5,
                                animateTrigger: animateRatings
                            )
                        }
                        .frame(height: 36)

                        // 甘味
                        HStack(spacing: 16) {
                            Text("甘味")
                                .font(.body)
                                .frame(width: 80, alignment: .leading)
                            
                            CollorRatingView(
                                rating: Double(viewModel.user.prosweetness),
                                maxRating: 5,
                                animateTrigger: animateRatings
                            )
                        }
                        .frame(height: 36)

                        // フレーバー
                        HStack(spacing: 16) {
                            Text("フレーバー")
                                .font(.body)
                                .frame(width: 80, alignment: .leading)
                            
                            CollorRatingView(
                                rating: Double(viewModel.user.proflavor),
                                maxRating: 5,
                                animateTrigger: animateRatings
                            )
                        }
                        .frame(height: 36)
                        
                        // フレーバータグの表示エリア（マイページと合わせる場合は縦並びに変更）
                        let tags = viewModel.user.flavorTags
                        if !tags.isEmpty {
                            HStack(alignment: .top, spacing: 6) {
                                Text("フレーバータグ:")
                                    .font(.body)
                                    .frame(width: 110, alignment: .leading)
                                
                                // 縦並び（VStack）にする場合
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
                                withAnimation(.easeInOut(duration: 1.5)) {
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
        .navigationTitle("好きな味わい詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}
