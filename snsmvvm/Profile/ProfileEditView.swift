//
//  ProfileEditView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/28.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    
    let user: User
    @State private var profileEditViewModel: ProfileEditViewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    
    let profileSize: CGFloat = 100
    
    init(user: User) {
        self.user = user
        _profileEditViewModel = State(initialValue: ProfileEditViewModel(user: user))
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // --- 1. プロフィール画像エリア ---
                        PhotosPicker(selection: $profileEditViewModel.selectedProfileItem, matching: .images) {
                            HStack(spacing: 15) {
                                Spacer()
                                ZStack {
                                    if let uiImage = profileEditViewModel.profileImage {
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
                                Spacer()
                            }
                        }
                        .padding(.top, 10)
                        
                        // --- 2. 各種編集フィールド ---
                        VStack(alignment: .leading, spacing: 0) {
                            editField(label: "名前", text: $profileEditViewModel.userName, placeholder: "名前")
                            
                            editField(label: "自己紹介", text: $profileEditViewModel.selfIntroduction, placeholder: "自己紹介を入力してください", isMultiLine: true)
                            
                            // 年齢選択
                            Button(action: { profileEditViewModel.isShowingAgePicker = true }) {
                                HStack {
                                    Text("年齢").foregroundColor(.primary)
                                    Spacer()
                                    Text(profileEditViewModel.userAge == 0 ? "選択してください" : "\(profileEditViewModel.userAge) 歳").foregroundColor(.secondary)
                                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 12)
                            .sheet(isPresented: $profileEditViewModel.isShowingAgePicker) {
                                AgeSelectionView { profileEditViewModel.userAge = $0 }
                            }
                            Divider()
                            
                            // 出身地選択
                            Button(action: { profileEditViewModel.isShowingPrefecturePicker = true }) {
                                HStack {
                                    Text("出身地").foregroundColor(.primary)
                                    Spacer()
                                    Text(profileEditViewModel.user.prefecture.isEmpty ? "選択してください" : profileEditViewModel.user.prefecture).foregroundColor(.secondary)
                                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 12)
                            .sheet(isPresented: $profileEditViewModel.isShowingPrefecturePicker) {
                                PrefectureSelectionView { profileEditViewModel.user.prefecture = $0 }
                            }
                            Divider()
                            
                            // --- 3. コーヒーの好み ---
                            Text("コーヒーの好み").font(.caption).fontWeight(.bold).foregroundColor(.secondary).padding(.top, 20).padding(.bottom, 10)
                            editField(label: "国名", text: $profileEditViewModel.favoriteCoffee, placeholder: "好きな国")
                            ratingRow(label: "苦味", rating: $profileEditViewModel.probitter)
                            ratingRow(label: "酸味", rating: $profileEditViewModel.proacidity)
                            ratingRow(label: "コク", rating: $profileEditViewModel.probody)
                            ratingRow(label: "香り", rating: $profileEditViewModel.proaroma)
                            
                            // 💡 フレーバー選択UI（タグ形式）
                            VStack(alignment: .leading, spacing: 10) {
                                Text("フレーバー").font(.body).padding(.top, 12)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                                    ForEach(profileEditViewModel.flavorOptions, id: \.self) { flavor in
                                        let isSelected = profileEditViewModel.proflavorList.contains(flavor)
                                        Text(flavor)
                                            .font(.system(size: 13, weight: .medium))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(isSelected ? Color.blue : Color(.systemGray6))
                                            .foregroundColor(isSelected ? .white : .primary)
                                            .cornerRadius(16)
                                            .onTapGesture {
                                                withAnimation {
                                                    if isSelected {
                                                        profileEditViewModel.proflavorList.removeAll { $0 == flavor }
                                                    } else {
                                                        profileEditViewModel.proflavorList.append(flavor)
                                                    }
                                                }
                                            }
                                    }
                                }
                                .padding(.bottom, 12)
                            }
                            Divider()
                            
                            // --- 4. お気に入りの道具 ---
                            Text("お気に入りの道具")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                            
                            // カバー画像（横幅いっぱい）
                            PhotosPicker(selection: $profileEditViewModel.selectedCoffeeItem, matching: .images) {
                                ZStack {
                                    if let uiImage = profileEditViewModel.favoriteCoffeeImage {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else if let urlString = profileEditViewModel.user.favoriteToolImageUrl, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                        }
                                    } else {
                                        Rectangle().fill(Color.gray.opacity(0.2))
                                    }
                                }
                                .frame(width: screenWidth)
                                .aspectRatio(4/3, contentMode: .fit)
                                .clipped()
                                .overlay(Text("画像をタップして変更").foregroundColor(.white).bold().shadow(radius: 2))
                            }
                            .padding(.horizontal, -20)
                            
                            // 道具の詳細入力
                            VStack(alignment: .leading, spacing: 15) {
                                editField(label: "ドリッパー", text: $profileEditViewModel.dripper, placeholder: "ドリッパー")
                                editField(label: "フィルター", text: $profileEditViewModel.paperFilter, placeholder: "ペーパーフィルター")
                                editField(label: "ケトル", text: $profileEditViewModel.kettle, placeholder: "ケトル")
                                editField(label: "サーバー", text: $profileEditViewModel.server, placeholder: "サーバー")
                                editField(label: "スケール", text: $profileEditViewModel.scale, placeholder: "スケール")
                                editField(label: "ミル", text: $profileEditViewModel.mill, placeholder: "ミル")
                                editField(label: "グラインダー", text: $profileEditViewModel.grinder, placeholder: "グラインダー")
                                editField(label: "マシン", text: $profileEditViewModel.espressoMachine, placeholder: "エスプレッソマシン")
                                editField(label: "プレス", text: $profileEditViewModel.frenchPress, placeholder: "フレンチプレス")
                            }
                            .padding(.top, 20)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: user) {
                profileEditViewModel.configure(with: user)
                if profileEditViewModel.profileImage == nil { profileEditViewModel.loadProfileImageFromUrl() }
                if profileEditViewModel.favoriteCoffeeImage == nil { profileEditViewModel.loadFavoriteCoffeeImageFromUrl() }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        guard let uid = Auth.auth().currentUser?.uid else {
                            print("ユーザーがログインしていません")
                            return
                        }
                        Task {
                            do {
                                let updatedUser = try await profileEditViewModel.uploadProfileAndSave(uid: uid)
                                await MainActor.run {
                                    userManager.currentUser = updatedUser
                                    profileViewModel.user = updatedUser
                                    dismiss()
                                }
                            } catch {
                                print("保存に失敗しました: \(error)")
                            }
                        }
                    }
                    .bold()
                }
            }
        }
    }
    
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String, isMultiLine: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(label).font(.body).frame(width: 80, alignment: .leading).padding(.vertical, 12)
                if isMultiLine {
                    TextField(placeholder, text: text, axis: .vertical).lineLimit(3...6).padding(.vertical, 12)
                } else {
                    TextField(placeholder, text: text).padding(.vertical, 12)
                }
            }
            Divider()
        }
    }
    
    @ViewBuilder
    private func ratingRow(label: String, rating: Binding<Int>) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label).font(.body).frame(width: 80, alignment: .leading).padding(.vertical, 12)
                HStack(spacing: 4) {
                    ForEach(1...profileEditViewModel.maxRating, id: \.self) { number in
                        let isSelected = number <= rating.wrappedValue
                        
                        // 💡 星のシステムイメージからコーヒー豆のカスタム画像に変更
                        Image(isSelected ? "coffeeBeanFill" : "coffeeBean")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isSelected ? .yellow : .gray.opacity(0.3)) // 必要に応じて色を調整
                            .contentShape(Rectangle()) // タップ判定を広げる
                            .onTapGesture {
                                rating.wrappedValue = number
                            }
                    }
                }
                Spacer()
            }
            Divider()
        }
    }
}
