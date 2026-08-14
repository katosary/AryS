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
                    VStack(spacing: 0) {
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
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Coffee Review")
                                .font(.title2).bold()
                                .padding(.top, 20)
                            
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Country: \(log.countryName)")
                                Text("Farm: \(log.farmName)")
                                Text("Roast: \(log.roastLevel)")
                                
                                if !log.aromaComment.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("香りの種類:").font(.subheadline).bold().foregroundColor(.secondary)
                                        Text(log.aromaComment).font(.body)
                                    }
                                    .padding(.top, 8)
                                }
                                
                                Text("Shop: \(log.shopName)")
                                
                                // プロフィール部分
                                HStack {
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
                        }
                        .padding(24)
                    }
                }
            }
            .presentationDetents([.fraction(1.0)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
            // 💡 修正：シート内の NavigationStack 直下に配置
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
