//
//  ProfileFavoriteCoffeeView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/22.
//

import SwiftUI

struct ProfileFavoriteCoffeeView: View {
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // --- 1. お気に入りのコーヒー（国名） ---
            HStack(alignment: .top) {
                Text("国")
                    .font(.subheadline)
                    .bold() // 💡 存在感を強く
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading) // 💡 50に縮小
                
                Text(profileViewModel.user.favoriteCoffee.isEmpty ? "未登録" : profileViewModel.user.favoriteCoffee)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .bold()
                Spacer()
            }
            
            Divider()
            
            // --- 2. 味のパラメーター（4項目） ---
            VStack(spacing: 16) { // 縦の間隔を少し広げてゆったり
                parameterRow(label: "苦味", rating: profileViewModel.user.probitter)
                parameterRow(label: "酸味", rating: profileViewModel.user.proacidity)
                parameterRow(label: "コク", rating: profileViewModel.user.probody)
                parameterRow(label: "香り", rating: profileViewModel.user.proaroma)
            }
            
            Divider()
            
            // --- 3. フレーバー ---
            HStack(alignment: .top) {
                Text("フレーバー")
                    .font(.subheadline)
                    .bold() // 💡 存在感を強く
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading) // ここだけ文字数に合わせて80に
                
                Text(profileViewModel.user.proflavor.isEmpty ? "未登録" : profileViewModel.user.proflavor)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .bold()
                Spacer()
            }
        }
        .padding(.horizontal, 12) // 💡 カードの内側の左右余白を少しタイトに
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity) // 💡 横幅いっぱいに広げる
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
    
    @ViewBuilder
    private func parameterRow(label: String, rating: Int) -> some View { // 👈 ここを Double に変える
        HStack(spacing: 15) {
            Text(label)
                .font(.subheadline)
                .bold()
                .foregroundColor(.primary)
                .frame(width: 45, alignment: .leading)
            
            // 型が Double になればそのまま渡せます
            CollorRatingView(rating: Double(rating), maxRating: profileViewModel.maxRating)
        }
        .padding(.trailing, 5)
    }
}

