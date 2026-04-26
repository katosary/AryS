//
//  TrendView.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/17.
//

import SwiftUI

// --- 1. メインの横スクロール画面 ---
struct MatchingView: View {
    var matchingViewModel = MatchingViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if matchingViewModel.isLoading {
                    VStack {
                        ProgressView()
                        Text("コーヒーを淹れています...")
                            .padding()
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(matchingViewModel.discoveredProfiles) { profile in
                                MatchProfileView(profile: profile)
                                    .containerRelativeFrame(.horizontal)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("トレンド")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if matchingViewModel.discoveredProfiles.isEmpty {
                    await matchingViewModel.fetchRecommendedProfiles()
                }
            }
        }
    }
}

// --- 2. 1人分のプロフィール表示 (カードの中身) ---
struct MatchProfileView: View {
    let profile: UserProfile // MatchingViewから渡されるテストデータ
    
    // デザイン定数
    let coverHeight: CGFloat = 320
    let profileSize: CGFloat = 120
    
    var body: some View {
        GeometryReader { geometry in
            // 画面の横幅を取得して、各パーツのサイズに適用
            let screenWidth = geometry.size.width
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // --- A. 上部：ビジュアルエリア ---
                    ZStack(alignment: .bottom) {
                        // カバー部分（コーヒーらしいブラウンのグラデーション）
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.brown.opacity(0.5), Color.black.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: screenWidth, height: coverHeight)
                        
                        // プロフィール写真（中央下部に配置）
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: profileSize, height: profileSize)
                            .foregroundColor(.white)
                            .background(Color(.systemGray4))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            // アイコンの半分（profileSize / 2）を下に突き出させる
                            .offset(y: profileSize / 2)
                    }
                    // ZStack自体の高さをカバー画像に合わせることで、下のVStackの起点を作る
                    .frame(width: screenWidth, height: coverHeight)
                    
                    // --- B. 下部：プロフィール詳細エリア ---
                    VStack(spacing: 16) {
                        // アイコンがはみ出している分のスペースを確保
                        Spacer().frame(height: profileSize / 2 + 12)
                        
                        // 名前
                        Text(profile.name)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        
                        // コーヒーのスタイル（タグ風）
                        Text(profile.coffeeStyle)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.brown.opacity(0.1))
                            .foregroundColor(.brown)
                            .cornerRadius(20)
                        
                        Divider()
                            .padding(.horizontal, 40)
                            .padding(.vertical, 8)
                        
                        // 自己紹介文
                        Text(profile.bio)
                            .font(.body)
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        // --- C. アクションボタン ---
                        HStack(spacing: 50) {
                            // スキップボタン
                            ActionButton(icon: "xmark", color: .red)
                                .onTapGesture {
                                    print("\(profile.name)さんをスキップしました")
                                }
                            
                            // いいねボタン
                            ActionButton(icon: "heart.fill", color: .green)
                                .onTapGesture {
                                    print("\(profile.name)さんにいいねしました！")
                                }
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 50) // 下スクロールの余白
                    }
                    .frame(width: screenWidth) // 横幅を画面に合わせる
                }
            }
        }
        .background(Color(.systemBackground)) // ダークモード対応
    }
}

// プレビュー用のコード（Xcodeのプレビュー画面で確認できます）
#Preview {
    MatchProfileView(profile: UserProfile(
        name: "テストユーザー",
        coffeeStyle: "浅煎り派 ☕️",
        bio: "ここに自己紹介が入ります。スワイプして次の人を確認できます。"
    ))
}

// ボタン用のサブView
struct ActionButton: View {
    let icon: String
    let color: Color
    var body: some View {
        Image(systemName: icon)
            .font(.title.bold())
            .foregroundColor(color)
            .frame(width: 60, height: 60)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(radius: 5)
    }
}
