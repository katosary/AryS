//
//  ProfileView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @Environment(ProfileViewModel.self) var profileViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isDetailShowing = false
    
    @State private var scrollPosition: Int? = 0
    
    let profileSize: CGFloat = 80   // アイコンのサイズ
    
    var body: some View {
        GeometryReader { outerGeometry in
            let totalWidth = outerGeometry.size.width
            let totalHeight = outerGeometry.size.height
             
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                NavigationStack {
                    // 縦方向のスクロールにページング動作を適用
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            ProfileDetailContentView(
                                totalWidth: totalWidth,
                                totalHeight: totalHeight,
                                profileSize: profileSize
                            )
                            .frame(width: totalWidth, height: totalHeight)
                            .containerRelativeFrame(.vertical)
                            
                            ProfileCoffeeLogView(
                                totalWidth: totalWidth,
                                totalHeight: totalHeight
                            )
                            .frame(width: totalWidth, height: totalHeight)
                            .containerRelativeFrame(.vertical)
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    .refreshable {
                        await profileViewModel.loadUserData()
                    }
                    .navigationTitle("プロフィール")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color(.systemBackground))
                }
                .onAppear {
                    Task {
                        await profileViewModel.loadUserData()
                    }
                }
                .scaleEffect(isDetailShowing ? 0.93 : 1.0)
                .blur(radius: isDetailShowing ? 8 : 0)
                .disabled(isDetailShowing)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: isDetailShowing)
    }
}

// MARK: - 1ページ目のプロフィール情報をまとめた独立ビュー
struct ProfileDetailContentView: View {
    @Environment(ProfileViewModel.self) var profileViewModel
    let totalWidth: CGFloat
    let totalHeight: CGFloat
    let profileSize: CGFloat
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                
                // 1. 一番上の背景画像（カバー画像） + 左下に道具の情報をオーバーレイ
                ZStack(alignment: .bottomLeading) {
                    Group {
                        if let urlString = profileViewModel.user.favoriteToolImageUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color(.secondarySystemBackground)
                                    .overlay(ProgressView())
                            }
                        } else {
                            Color(.secondarySystemBackground)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.secondary)
                                )
                        }
                    }
                    .frame(width: totalWidth)
                    .aspectRatio(4/3, contentMode: .fit)
                    .clipped()
                    
                    // --- 道具の情報のみを左下に配置 ---
                    let toolData: [(String, String)] = [
                        ("ドリッパー", profileViewModel.user.dripper ?? ""),
                        ("ペーパー", profileViewModel.user.paperFilter ?? ""),
                        ("ケトル", profileViewModel.user.kettle ?? ""),
                        ("サーバー", profileViewModel.user.server ?? ""),
                        ("スケール", profileViewModel.user.scale ?? ""),
                        ("ミル", profileViewModel.user.mill ?? ""),
                        ("グラインダー", profileViewModel.user.grinder ?? ""),
                        ("マシン", profileViewModel.user.espressoMachine ?? ""),
                        ("プレス", profileViewModel.user.frenchPress ?? "")
                    ].filter { !$0.1.isEmpty }
                    
                    if !toolData.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(toolData, id: \.0) { label, value in
                                HStack(spacing: 6) {
                                    Text(label)
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(value)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .shadow(color: .black.opacity(0.8), radius: 2)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        // 背景にグラデーションを敷いて文字の視認性を確保
                        .background(
                            LinearGradient(
                                colors: [.black.opacity(0.7), .clear],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                    }
                }
                
                // 2. インスタ風レイアウト（アイコン、ユーザー名、自己紹介など）
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 16) {
                        // プロフィールアイコン
                        Group {
                            if let urlString = profileViewModel.user.profileImageUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color(.systemGray3))
                            }
                        }
                        .frame(width: profileSize, height: profileSize)
                        .clipShape(Circle())
                        
                        // ユーザー名・年齢・場所など
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profileViewModel.user.userName)
                                .font(.title3)
                                .bold()
                            
                            HStack(spacing: 8) {
                                if profileViewModel.user.userAge > 0 {
                                    Text("\(profileViewModel.user.userAge)歳")
                                }
                                if !profileViewModel.user.prefecture.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "mappin.and.ellipse")
                                        Text(profileViewModel.user.prefecture)
                                    }
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // 自己紹介文（すべて表示されるように制限を解除）
                    if !profileViewModel.user.selfIntroduction.isEmpty {
                        Text(profileViewModel.user.selfIntroduction)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // --- 1. お気に入りのコーヒー（国名） ---
                    HStack(alignment: .top) {
                        Text("国")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .leading)
                        
                        Text(profileViewModel.user.favoriteCoffee.isEmpty ? "未登録" : profileViewModel.user.favoriteCoffee)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .bold()
                    }
                    
                    // --- 2. 味のパラメータ（縦1列） ---
                    VStack(spacing: 8) {
                        parameterRow(label: "苦味", rating: profileViewModel.user.probitter)
                        parameterRow(label: "酸味", rating: profileViewModel.user.proacidity)
                        parameterRow(label: "コク", rating: profileViewModel.user.probody)
                        parameterRow(label: "香り", rating: profileViewModel.user.proaroma)
                    }
                    .padding(.top, 4)
                    
                    // --- 3. フレーバー（タグ形式） ---
                    HStack(alignment: .top) {
                        Text("フレーバー")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        
                        let flavorString = profileViewModel.user.proflavor
                        if flavorString.isEmpty {
                            Text("未登録")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .bold()
                        } else {
                            // カンマ区切りの文字列を想定して配列に分割（前後の空白も削除）
                            let flavorTags = flavorString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                            
                            if flavorTags.isEmpty {
                                Text("未登録")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .bold()
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(flavorTags, id: \.self) { tag in
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
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // 下スワイプを促すアイコン
                VStack(spacing: 4) {
                    Image(systemName: "chevron.compact.down")
                        .font(.title2)
                    Text("スワイプして投稿を見る")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    @ViewBuilder
    private func parameterRow(label: String, rating: Int) -> some View {
        HStack(spacing: 15) {
            Text(label)
                .font(.subheadline)
                .frame(width: 45, alignment: .leading)
            
            EmptyRatingView(rating: Double(rating))
        }
        .padding(.trailing, 5)
    }
}

#Preview {
    let profileViewModel = ProfileViewModel()
    return ProfileView()
        .environment(profileViewModel)
        .environmentObject(AuthManager())
}
