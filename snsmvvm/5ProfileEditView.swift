//
//  ProfileEditView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/28.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var profileViewModel: ProfileViewModel
    
    let coverHeight: CGFloat = 200 // 編集時は少し低めが見やすい
    let profileSize: CGFloat = 100
    
    var body: some View {
        NavigationStack {
            // 💡 GeometryReaderで画面の横幅を取得
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // --- 1. 画像エリア ---
                        ZStack(alignment: .bottom) {
                            
                            // A. カバー写真
                            ZStack {
                                if let uiImage = profileViewModel.favoriteCoffeeImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: screenWidth, height: coverHeight) // 💡 横幅を画面幅に固定
                                        .clipped() // 💡 はみ出た分を物理的にカット
                                } else {
                                    Color.gray.opacity(0.3)
                                        .frame(width: screenWidth, height: coverHeight)
                                }
                            }
                            .overlay(
                                PhotosPicker(selection: $profileViewModel.selectedCoffeeItem, matching: .images) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 20))
                                        .padding(10)
                                        .background(.black.opacity(0.5))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                                    .padding(12),
                                alignment: .topTrailing
                            )
                            
                            // B. プロフィール写真
                            ZStack {
                                if let uiImage = profileViewModel.profileImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray.opacity(0.6))
                                        .background(Color.white)
                                }
                            }
                            .frame(width: profileSize, height: profileSize)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .offset(y: profileSize * 0.5) // 💡 突き出し量を調整
                            .overlay(
                                PhotosPicker(selection: $profileViewModel.selectedProfileItem, matching: .images) {
                                    Image(systemName: "pencil.circle.fill")
                                        .symbolRenderingMode(.multicolor)
                                        .font(.system(size: 32))
                                        .background(Color.white.clipShape(Circle()))
                                }
                                    .offset(x: 35, y: 35),
                                alignment: .bottom
                            )
                        }
                        .padding(.bottom, profileSize * 0.5 + 20) // 💡 下のフィールドとの余白を確保
                        
                        // --- 2. テキスト入力エリア ---
                        VStack(alignment: .leading, spacing: 25) {
                            editField(label: "ユーザー名", text: $profileViewModel.userName, placeholder: "ユーザー名を入力")
                            TextField("自己紹介を入力してください",text: $profileViewModel.selfIntroduction, axis: .vertical)
                                    .font(.body)
                                    .lineLimit(3...6) // 最小3行、最大6行まで表示
                            editField(label: "お気に入りのコーヒー", text: $profileViewModel.favoriteCoffee, placeholder: "例: エチオピア イルガチェフェ")
                            HStack {
                                Text("苦味")
                                    .padding(5)
                                    .font(.system(size:30))
                                Text("弱い").padding(5)
                                HStack {
                                    ForEach(1...profileViewModel.maxRating, id: \.self) { number in
                                        profileViewModel.image(for: number, rating: profileViewModel.probitter)
                                            .font(.system(size: 20))
                                            .foregroundColor(number > profileViewModel.probitter ? profileViewModel.offColor : profileViewModel.onColor)
                                            .onTapGesture { profileViewModel.probitter = number }
                                    }
                                }
                                Text("強い").padding(5)
                            }
                            Spacer()
                            
                            HStack {
                                Text("酸味")
                                    .padding(5)
                                    .font(.system(size:30))
                                Text("弱い").padding(5)
                                HStack {
                                    ForEach(1...profileViewModel.maxRating, id: \.self) { number in
                                        profileViewModel.image(for: number, rating: profileViewModel.proacidity)
                                            .font(.system(size: 20))
                                            .foregroundColor(number > profileViewModel.proacidity ? profileViewModel.offColor : profileViewModel.onColor)
                                            .onTapGesture { profileViewModel.proacidity = number }
                                    }
                                }
                                Text("強い").padding(5)
                            }
                            Spacer()
                            
                            HStack {
                                Text("コク")
                                    .padding(5)
                                    .font(.system(size:30))
                                Text("弱い").padding(5)
                                HStack {
                                    ForEach(1...profileViewModel.maxRating, id: \.self) { number in
                                        profileViewModel.image(for: number, rating: profileViewModel.probody)
                                            .font(.system(size: 20))
                                            .foregroundColor(number > profileViewModel.probody ? profileViewModel.offColor : profileViewModel.onColor)
                                            .onTapGesture { profileViewModel.probody = number }
                                    }
                                }
                                Text("強い").padding(5)
                            }
                            
                            Spacer()
                            
                            HStack {
                                Text("香り")
                                    .padding(5)
                                    .font(.system(size:30))
                                Text("弱い").padding(5)
                                HStack {
                                    ForEach(1...profileViewModel.maxRating, id: \.self) { number in
                                        profileViewModel.image(for: number, rating: profileViewModel.proaroma)
                                            .font(.system(size: 20))
                                            .foregroundColor(number > profileViewModel.proaroma ? profileViewModel.offColor : profileViewModel.onColor)
                                            .onTapGesture { profileViewModel.proaroma = number }
                                    }
                                }
                                Text("強い").padding(5)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(width: screenWidth) // 💡 入力エリアの幅も画面幅に固定
                    }
                }
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        profileViewModel.updateUser()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
    
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: text)
                .font(.body)
                .padding(.vertical, 4)
            
            Divider()
        }
    }
}
