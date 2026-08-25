//
//  CoffeeLogDetailView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/13.
//

import SwiftUI

struct CoffeeLogDetailView: View {
    let log: Log
    let author: User?
    let authorName: String
    
    let coffeeLogViewModel: CoffeeLogViewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    
    @State private var animateRatings = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width
                let cardHeight = cardWidth * (16 / 9)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // --- 1. 画像エリア（上部） ---
                            Group {
                                if let previewImage = log.previewImage {
                                    Image(uiImage: previewImage)
                                        .resizable()
                                        .scaledToFill()
                                } else if let urlString = log.imageUrl, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                                    placeholder: { ProgressView() }
                                }
                            }
                            .frame(width: cardWidth, height: cardHeight)
                            .clipped()
                            
                            // --- 2. 下部：詳細エリア ---
                            VStack(alignment: .leading, spacing: 20) {
                                Text("コーヒー豆情報")
                                    .font(.headline)
                                    .padding(.top, 4)
                                    .id("DetailTop")
                                
                                VStack(alignment: .leading, spacing: 14) {
                                    // 店舗名
                                    HStack(spacing: 16) {
                                        Text("店舗名")
                                            .font(.body)
                                            .frame(width: 80, alignment: .leading)
                                        Text(log.shopName)
                                            .font(.body)
                                    }
                                    
                                    // ブレンドかどうかで項目を動的に切り替え
                                    if !log.blend.isEmpty && log.farmName.isEmpty {
                                        // --- ブレンドの場合 ---
                                        HStack(spacing: 16) {
                                            Text("ブレンド名")
                                                .font(.body)
                                                .frame(width: 80, alignment: .leading)
                                            Text(log.blend)
                                                .font(.body)
                                        }
                                        
                                        HStack(spacing: 16) {
                                            Text("使用国")
                                                .font(.body)
                                                .frame(width: 80, alignment: .leading)
                                            Text(log.countryName)
                                                .font(.body)
                                        }
                                    } else {
                                        // --- シングルオリジンの場合 ---
                                        HStack(spacing: 16) {
                                            Text("生産国")
                                                .font(.body)
                                                .frame(width: 80, alignment: .leading)
                                            Text(log.countryName)
                                                .font(.body)
                                        }
                                        
                                        if !log.blend.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("銘柄 / 品種")
                                                    .font(.body)
                                                    .frame(width: 80, alignment: .leading)
                                                Text(log.blend)
                                                    .font(.body)
                                            }
                                        }
                                        
                                        if !log.farmName.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("農園名")
                                                    .font(.body)
                                                    .frame(width: 80, alignment: .leading)
                                                Text(log.farmName)
                                                    .font(.body)
                                            }
                                        }
                                        
                                        if !log.grade.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("グレード")
                                                    .font(.body)
                                                    .frame(width: 80, alignment: .leading)
                                                Text(log.grade)
                                                    .font(.body)
                                            }
                                        }
                                        
                                        // 焙煎度（シングルオリジンなどの場合のみ表示）
                                        HStack(spacing: 16) {
                                            Text("焙煎度")
                                                .font(.body)
                                                .frame(width: 80, alignment: .leading)
                                            Text(log.roastLevel)
                                                .font(.body)
                                        }
                                    }
                                }
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                // --- 3. RatingView エリア ---
                                VStack(alignment: .leading, spacing: 18) {
                                    HStack(alignment: .bottom) {
                                        Text("味わい評価")
                                            .font(.headline)
                                            .bold()
                                        
                                        Spacer()
                                        
                                        Text("弱 ──────────── 強")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .padding(.trailing, 20)
                                    }
                                    
                                    // 苦味
                                    HStack(spacing: 16) {
                                        Text("苦味")
                                            .font(.body)
                                            .frame(width: 80, alignment: .leading)
                                        
                                        CollorRatingView(
                                            rating: Double(log.bitternessrating),
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
                                            rating: Double(log.acidityrating),
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
                                            rating: Double(log.bodyrating),
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
                                            rating: Double(log.sweetnessrating),
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
                                            rating: Double(log.flavorrating),
                                            maxRating: 5,
                                            animateTrigger: animateRatings
                                        )
                                    }
                                    .frame(height: 36)
                                    
                                    // 香りのタグ（flavorTags）の表示エリア
                                    if let tags = log.flavorTags, !tags.isEmpty {
                                        HStack(spacing: 6) {
                                            Text("フレーバータグ:").font(.subheadline).bold().foregroundColor(.secondary)
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
                                    
                                    if !log.memo.isEmpty {
                                        HStack(spacing: 6) {
                                            Text("コメント:").font(.subheadline).bold().foregroundColor(.secondary)
                                            Text(log.memo).font(.body)
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
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                // --- 4. プロフィール部分 ---
                                HStack(spacing: 12) {
                                    Button {
                                        coffeeLogViewModel.onTapProfile(currentProfileUser: profileViewModel.user)
                                    } label: {
                                        HStack {
                                            let displayUser = coffeeLogViewModel.isMyPost ? profileViewModel.user : author
                                            if let urlString = displayUser?.profileImageUrl, !urlString.isEmpty, let url = URL(string: urlString) {
                                                AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                                                placeholder: { Circle().fill(Color.gray) }
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.circle.fill").resizable().frame(width: 40, height: 40).foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    
                                    let displayUser = coffeeLogViewModel.isMyPost ? profileViewModel.user : author
                                    Text(displayUser?.userName ?? authorName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(24)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo("DetailTop", anchor: .top)
                    }
                }
            }
            .presentationDetents([.fraction(1.0)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
            .navigationDestination(
                isPresented: Binding(
                    get: { coffeeLogViewModel.shouldNavigateToProfile },
                    set: { coffeeLogViewModel.shouldNavigateToProfile = $0 }
                )
            ) {
                OtherUserProfileView(user: coffeeLogViewModel.targetUserForProfile)
            }
        }
    }
}
