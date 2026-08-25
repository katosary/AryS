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
                        .sheet(isPresented: $profileEditViewModel.isShowingImageCropView) {
                            if let inputImage = profileEditViewModel.tempSelectedUIImage {
                                ImageCropView(inputImage: inputImage) { croppedImage in
                                    profileEditViewModel.profileImage = croppedImage
                                }
                            }
                        }
                        
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
                                    .presentationDetents([.medium, .large])
                            }
                            Divider()
                            
                            // --- 3. コーヒーの好み ---
                            Text("コーヒーの好み").font(.caption).fontWeight(.bold).foregroundColor(.secondary).padding(.top, 20).padding(.bottom, 10)
                            
                            ratingRow(label: "苦味", rating: $profileEditViewModel.probitter)
                            ratingRow(label: "酸味", rating: $profileEditViewModel.proacidity)
                            ratingRow(label: "コク", rating: $profileEditViewModel.probody)
                            ratingRow(label: "甘味", rating: $profileEditViewModel.prosweetness)
                            ratingRow(label: "フレーバー", rating: $profileEditViewModel.proflavor)
                            
                            // 💡 フレーバー選択UI（制限なしの複数選択）
                            VStack(alignment: .leading, spacing: 12) {
                                Text("お気に入りのフレーバー（最大3つまで）")
                                    .font(.body)
                                    .padding(.top, 12)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(profileEditViewModel.flavorOptions, id: \.self) { aroma in
                                        let isSelected = profileEditViewModel.selectedFlavors.contains(aroma)
                                        // 💡 3つに達しているかどうかの判定
                                        let isMaxReached = profileEditViewModel.selectedFlavors.count >= 3
                                        
                                        Button(action: {
                                            withAnimation {
                                                var current = profileEditViewModel.selectedFlavors
                                                if isSelected {
                                                    // 選択済みなら外す
                                                    current.removeAll { $0 == aroma }
                                                } else {
                                                    // 未選択で、まだ3つ未満なら追加する
                                                    if current.count < 3 {
                                                        current.append(aroma)
                                                    }
                                                }
                                                // 配列のインスタンスを新しくして確実に変更を通知
                                                profileEditViewModel.selectedFlavors = current
                                            }
                                        }) {
                                            HStack {
                                                Text(aroma)
                                                    .font(.system(size: 14, weight: .medium))
                                                Spacer()
                                                if isSelected {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 14, weight: .bold))
                                                }
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                            // 💡 3つに達していて未選択の項目は、少し薄くして押せない雰囲気を出す
                                            .background(isSelected ? Color.blue : Color(.systemGray6))
                                            .foregroundColor(isSelected ? .white : (isMaxReached && !isSelected ? .gray.opacity(0.6) : .primary))
                                            .cornerRadius(12)
                                        }
                                        // 💡 3つに達しているとき、未選択のボタンはタップ不可にしたい場合は .disabled() をつけてもOK
                                        // .disabled(isMaxReached && !isSelected)
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
                            
                            // カバー画像
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
            .task {
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
                         
                        Image(isSelected ? "coffeeBeanFill" : "coffeeBean")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isSelected ? .yellow : .gray.opacity(0.3))
                            .contentShape(Rectangle())
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
