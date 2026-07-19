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
            RatingView(rating: Double(rating), maxRating: profileViewModel.maxRating)
        }
        .padding(.trailing, 5)
    }
}

// 💡 星のマスク描画部分を、すっきり共通コンポーネント化しました
struct CustomStarRating: View {
    let rating: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in Image(systemName: "star").foregroundColor(.gray.opacity(0.4)) }
            }
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in Image(systemName: "star.fill").foregroundColor(.orange) }
            }
            .mask(
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width * CGFloat(rating / 5.0))
                }
            )
        }
    }
}

struct RatingView: View {
    let rating: Double // 👈 Int から Double に変更
    let maxRating: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Text("◀ 弱い")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
            
            Spacer()
            
            // --- 小数対応の星描画エリア ---
            ZStack(alignment: .leading) {
                // 下地：グレーの星（5つ）
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(.systemGray4))
                    }
                }
                
                // 上書き：オレンジの星（5つ）を、ratingの数値分だけマスクして表示
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    }
                }
                .mask(
                    GeometryReader { geometry in
                        Rectangle()
                        // rating が 2.5 なら、2.5 / 5.0 = 50% の横幅だけオレンジにする
                            .frame(width: geometry.size.width * CGFloat(rating / Double(maxRating)))
                    }
                )
            }
            
            Spacer()
            
            Text("強い ▶")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
