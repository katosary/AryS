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
                                    rating: animateRatings ? Double(profileViewModel.user.probitter) : 0,
                                    maxRating: 5
                                )
                            }
                            .frame(height: 36)
                            
                            // 酸味
                            HStack(spacing: 16) {
                                Text("酸味")
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                CollorRatingView(
                                    rating: animateRatings ? Double(profileViewModel.user.proacidity) : 0,
                                    maxRating: 5
                                )
                            }
                            .frame(height: 36)
                            
                            // コク
                            HStack(spacing: 16) {
                                Text("コク")
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                CollorRatingView(
                                    rating: animateRatings ? Double(profileViewModel.user.probody) : 0,
                                    maxRating: 5
                                )
                            }
                            .frame(height: 36)
                            
                            // 甘味（prosweetness）
                            HStack(spacing: 16) {
                                Text("甘味")
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                CollorRatingView(
                                    rating: animateRatings ? Double(profileViewModel.user.prosweetness) : 0,
                                    maxRating: 5
                                )
                            }
                            .frame(height: 36)
                            
                            // フレーバー（proflavor） ✨追加
                            HStack(spacing: 16) {
                                Text("フレーバー")
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                CollorRatingView(
                                    rating: animateRatings ? Double(profileViewModel.user.proflavor) : 0,
                                    maxRating: 5
                                )
                            }
                            .frame(height: 36)
                            
                            // フレーバータグの表示エリア
                            let tags = profileViewModel.user.flavorTags
                            if !tags.isEmpty {
                                HStack(spacing: 6) {
                                    Text("フレーバータグ:")
                                        .font(.body)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 6) {
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
                                }
                                .padding(.top, 4)
                            }
                        }
                        .onAppear {
                            if !animateRatings {
                                Task {
                                    try? await Task.sleep(nanoseconds: 200_000_000)
                                    withAnimation(.easeInOut(duration: 2.0)) {
                                        animateRatings = true
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    //フレーバータグの下にこれまでのランキング３位以内までを入力 これは各投稿のメニューから選択できるようにしたい
                }
            }
            .navigationTitle("好きな味わい詳細")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    let viewModel: ProfileViewModel = {
        let vm = ProfileViewModel()
        vm.user.probitter = 4
        vm.user.proacidity = 3
        vm.user.probody = 5
        vm.user.prosweetness = 4
        vm.user.proflavor = 4 // ← プレビュー用に追加
        vm.user.flavorTags = ["フルーティー", "チョコレート", "ナッティ"]
        return vm
    }()
    
    return ProfileFlavorDetailView()
        .environment(viewModel)
}
