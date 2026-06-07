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
            // 💡 ここで画面全体の背景色を指定
            ZStack {
                Color(.systemBackground).ignoresSafeArea() // 背景をシステム背景色に
                
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
                        .scrollContentBackground(.hidden) // 💡 ScrollViewのデフォルト背景を消す
                    }
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
// --- 2. 1人分のプロフィール表示 (カードデザイン版) ---
struct MatchProfileView: View {
    let profile: UserProfile
    let profileSize: CGFloat = 110
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            VStack(spacing: 0) {
                // --- A. 上部：ビジュアルエリア ---
                ZStack(alignment: .bottom) {
                    // 背景グラデーション（ダークモードでも違和感のない色に）
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.brown.opacity(0.6), Color.primary.opacity(0.3)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: screenHeight * 0.4)
                    
                    // プロフィール写真
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: profileSize, height: profileSize)
                        .foregroundColor(Color(.systemGray3)) // アイコンの色
                        .background(Color(.systemBackground)) // 背景色
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(.secondarySystemBackground), lineWidth: 3))
                        .offset(y: profileSize / 3)
                }
                
                // --- B. 下部：プロフィール詳細エリア ---
                VStack(spacing: 12) {
                    Spacer().frame(height: profileSize / 3 + 10)
                    
                    Text(profile.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary) // 明示的にprimary指定
                    
                    Text(profile.bio)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .padding(.horizontal, 20)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // アクションボタン
                    HStack(spacing: 20) {
                        ActionButton(icon: "person.crop.circle", color: .blue)
                        ActionButton(icon: "square.and.arrow.down", color: .red)
                        ActionButton(icon: "heart.fill", color: .red)
                    }
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(.secondarySystemBackground)) // カード背景をシステム標準のグレーに
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
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

struct ActionButton: View {
    let icon: String
    let color: Color
    var body: some View {
        Image(systemName: icon)
            .font(.title.bold())
            .foregroundColor(color)
            .frame(width: 60, height: 60)
            .background(Color(.systemBackground)) // 💡 背景をシステム背景色に
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.1), radius: 5) // 影を薄く
    }
}
