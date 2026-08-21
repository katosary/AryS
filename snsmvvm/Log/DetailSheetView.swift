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
    
    // ViewModel を受け取るプロパティを用意
    let coffeeLogViewModel: CoffeeLogViewModel
    
    // ProfileViewModel もシート内で使うため @Environment で受け取る
    @Environment(ProfileViewModel.self) var profileViewModel
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width
                let cardHeight = cardWidth * (16 / 9)
                
                ScrollView {
                    // 💡 スクロールビューの中身全体を左寄せにする
                    VStack(alignment: .leading, spacing: 0) {
                        // --- 1. 画像エリア ---
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
                            Text("Coffee Review")
                                .font(.title2).bold()
                                .padding(.top, 4)
                            
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Country: \(log.countryName)")
                                    .font(.body)
                                Text("Farm: \(log.farmName)")
                                    .font(.body)
                                Text("Roast: \(log.roastLevel)")
                                    .font(.body)
                                Text("Shop: \(log.shopName)")
                                    .font(.body)
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            // --- 3. RatingView (CollorRatingView) の追加 ---
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Flavor Ratings")
                                    .font(.headline)
                                    .bold()
                                
                                // Bitterness
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Bitterness").font(.subheadline).bold()
                                    CollorRatingView(rating: Double(log.bitternessrating), maxRating: 5)
                                }
                                
                                // Acidity
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Acidity").font(.subheadline).bold()
                                    CollorRatingView(rating: Double(log.acidityrating), maxRating: 5)
                                }
                                
                                // Body
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Body").font(.subheadline).bold()
                                    CollorRatingView(rating: Double(log.bodyrating), maxRating: 5)
                                }
                                
                                // Aroma
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Aroma").font(.subheadline).bold()
                                    CollorRatingView(rating: Double(log.aromarating), maxRating: 5)
                                }
                                
                                // 💡 香りのタグ（aromaTags）の表示エリア
                                if let tags = log.aromaTags, !tags.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Aroma Tags:").font(.subheadline).bold().foregroundColor(.secondary)
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
                                
                                if !log.aromaComment.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("香りのコメント:").font(.subheadline).bold().foregroundColor(.secondary)
                                        Text(log.aromaComment).font(.body)
                                    }
                                    .padding(.top, 4)
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
                        .frame(maxWidth: .infinity, alignment: .leading) // 👈 詳細エリア全体を左寄せに固定
                        .padding(24)
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
