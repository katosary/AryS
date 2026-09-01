//
//  CoffeeLogDetailView.swift
//  snsmvvm
//

import SwiftUI

struct CoffeeLogDetailView: View {
    let log: Log
    let author: User?
    let authorName: String
    
    let coffeeLogViewModel: CoffeeLogViewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    
    @State private var animateRatings = false
    // 💡 CoffeeLogView と同じようにフルスクリーン表示用の状態を持つ
    @State private var isShowingProfileFullCover = false
    
    var body: some View {
        // 💡 独自の NavigationStack を持たせることで、単体のシートからでも安全にフルスクリーンや画面遷移を行えるようにする
        NavigationStack {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width
                let cardHeight = cardWidth * (16 / 9)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // --- 1. 画像エリア ---
                            Group {
                                if let previewImage = log.previewImage {
                                    Image(uiImage: previewImage)
                                        .resizable()
                                        .scaledToFill()
                                } else if let uiImage = coffeeLogViewModel.remoteImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Color(.secondarySystemBackground)
                                }
                            }
                            .frame(width: cardWidth, height: cardHeight)
                            .clipped()
                            
                            // --- 2. 下部詳細エリア ---
                            VStack(alignment: .leading, spacing: 20) {
                                Text("コーヒー豆情報")
                                    .font(.headline)
                                    .padding(.top, 4)
                                    .id("DetailTop")
                                
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack(spacing: 16) {
                                        Text("店舗名")
                                            .font(.body)
                                            .frame(width: 80, alignment: .leading)
                                        Text(log.shopName)
                                            .font(.body)
                                    }
                                    
                                    if log.isBlend == true {
                                        if let blend = log.blend, !blend.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("ブレンド名").frame(width: 80, alignment: .leading)
                                                Text(blend)
                                            }
                                        }
                                        if let country1 = log.blendCountry1, !country1.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("使用国1").frame(width: 80, alignment: .leading)
                                                Text(country1)
                                            }
                                        }
                                        if let country2 = log.blendCountry2, !country2.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("使用国2").frame(width: 80, alignment: .leading)
                                                Text(country2)
                                            }
                                        }
                                        if let country3 = log.blendCountry3, !country3.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("使用国3").frame(width: 80, alignment: .leading)
                                                Text(country3)
                                            }
                                        }
                                    } else {
                                        if !log.countryName.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("生産国").frame(width: 80, alignment: .leading)
                                                Text(log.countryName)
                                            }
                                        }
                                        if let brand = log.brand, !brand.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("銘柄 / 品種").frame(width: 80, alignment: .leading)
                                                Text(brand)
                                            }
                                        }
                                        if !log.farmName.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("農園名").frame(width: 80, alignment: .leading)
                                                Text(log.farmName)
                                            }
                                        }
                                        if !log.grade.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("グレード").frame(width: 80, alignment: .leading)
                                                Text(log.grade)
                                            }
                                        }
                                        if !log.roastLevel.isEmpty {
                                            HStack(spacing: 16) {
                                                Text("焙煎度").frame(width: 80, alignment: .leading)
                                                Text(log.roastLevel)
                                            }
                                        }
                                    }
                                }
                                
                                Divider().padding(.vertical, 4)
                                
                                // --- 3. 味わい評価 ---
                                VStack(alignment: .leading, spacing: 18) {
                                    HStack(alignment: .bottom) {
                                        Text("味わい評価").font(.headline).bold()
                                        Spacer()
                                        Text("弱 ──────────── 強").font(.subheadline).foregroundColor(.primary).padding(.trailing, 20)
                                    }
                                    
                                    HStack(spacing: 16) {
                                        Text("苦味").frame(width: 80, alignment: .leading)
                                        CollorRatingView(rating: Double(log.bitternessrating), maxRating: 5, animateTrigger: animateRatings)
                                    }.frame(height: 36)
                                    
                                    HStack(spacing: 16) {
                                        Text("酸味").frame(width: 80, alignment: .leading)
                                        CollorRatingView(rating: Double(log.acidityrating), maxRating: 5, animateTrigger: animateRatings)
                                    }.frame(height: 36)
                                    
                                    HStack(spacing: 16) {
                                        Text("コク").frame(width: 80, alignment: .leading)
                                        CollorRatingView(rating: Double(log.bodyrating), maxRating: 5, animateTrigger: animateRatings)
                                    }.frame(height: 36)
                                    
                                    HStack(spacing: 16) {
                                        Text("甘味").frame(width: 80, alignment: .leading)
                                        CollorRatingView(rating: Double(log.sweetnessrating), maxRating: 5, animateTrigger: animateRatings)
                                    }.frame(height: 36)
                                    
                                    HStack(spacing: 16) {
                                        Text("フレーバー").frame(width: 80, alignment: .leading)
                                        CollorRatingView(rating: Double(log.flavorrating), maxRating: 5, animateTrigger: animateRatings)
                                    }.frame(height: 36)
                                    
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
                                        }.padding(.top, 4)
                                    }
                                    
                                    if !log.memo.isEmpty {
                                        HStack(spacing: 6) {
                                            Text("一言メモ:").font(.subheadline).bold().foregroundColor(.secondary)
                                            Text(log.memo).font(.body)
                                        }.padding(.top, 4)
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
                                
                                Divider().padding(.vertical, 4)
                                
                                // --- 4. プロフィール部分（CoffeeLogViewと同じフルスクリーンに遷移） ---
                                HStack(spacing: 12) {
                                    Button {
                                        isShowingProfileFullCover = true
                                    } label: {
                                        HStack {
                                            if let uiImage = coffeeLogViewModel.remoteAuthorImage {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(.gray)
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
            // 💡 CoffeeLogView と完全に同じロジックで OtherUserProfileView を構築・表示
            .fullScreenCover(isPresented: $isShowingProfileFullCover) {
                NavigationStack {
                    let baseUser = coffeeLogViewModel.isMyPost ? profileViewModel.user : author
                    
                    let targetUser = User(
                        id: (baseUser?.id?.isEmpty == false) ? baseUser!.id! : log.userId,
                        userName: baseUser?.userName ?? authorName,
                        email: baseUser?.email ?? "",
                        profileImageUrl: baseUser?.profileImageUrl ?? ""
                    )
                    
                    OtherUserProfileView(user: targetUser)
                }
            }
        }
    }
}
