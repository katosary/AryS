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
            .task {
                if matchingViewModel.discoveredProfiles.isEmpty {
                    await matchingViewModel.fetchRecommendedProfiles()
                }
            }
        }
    }
}

// --- 2. 1人分のプロフィール表示 (カードの中身) ---
// --- 2. 1人分のプロフィール表示 (カードデザイン版) ---
struct MatchProfileView: View {
    let profile: UserProfile
    
    // デザイン定数
    let profileSize: CGFloat = 110
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            // カード本体
            VStack(spacing: 0) {
                
                // --- A. 上部：ビジュアルエリア ---
                ZStack(alignment: .bottom) {
                    // カバー画像部分（グラデーション）
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.brown.opacity(0.6), Color.black.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        // カードの半分弱を画像にする
                        .frame(height: screenHeight * 0.4)
                    
                    // プロフィール写真（中央に配置）
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: profileSize, height: profileSize)
                        .foregroundColor(.white)
                        .background(Color(.systemGray4))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .offset(y: profileSize / 3) // 少しだけ下にはみ出させる
                }
                
                // --- B. 下部：プロフィール詳細エリア ---
                VStack(spacing: 12) {
                    Spacer().frame(height: profileSize / 3 + 10)
                    
                    // 名前
                    Text(profile.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    
                    // コーヒーのスタイル
                    Text(profile.coffeeStyle)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.brown.opacity(0.1))
                        .foregroundColor(.brown)
                        .cornerRadius(4) // ここも角を少し硬めに
                    
                    Divider()
                        .padding(.horizontal, 40)
                    
                    // 自己紹介（スクロールなしで収まるよう最大3行などに制限可能）
                    Text(profile.bio)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .padding(.horizontal, 20)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // --- C. アクションボタン ---
                    HStack(spacing: 60) {
                        ActionButton(icon: "xmark", color: .red)
                            .onTapGesture { print("Skip") }
                        
                        ActionButton(icon: "heart.fill", color: .green)
                            .onTapGesture { print("Like") }
                    }
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.white) // カードの背景色
            // --- 角を尖らせて影をつける設定 ---
            .cornerRadius(30) // 角を尖らせる
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5) // 後ろに影
            .padding(.horizontal, 20) // 左右に余白を作って「カード」に見せる
            .padding(.vertical, 30)   // 上下にも余白
        }
    }
}

#Preview {
    ContentView()
}
//// プレビュー用のコード（Xcodeのプレビュー画面で確認できます）
//#Preview {
//    MatchProfileView(profile: UserProfile(
//        name: "テストユーザー",
//        coffeeStyle: "浅煎り派 ☕️",
//        bio: "ここに自己紹介が入ります。スワイプして次の人を確認できます。"
//    ))
//}

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
