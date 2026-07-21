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
    // 💡 外部からユーザーデータを受け取れるようにする
    @State private var profileEditViewModel: ProfileEditViewModel
    
    init(user: User) {
        // 受け取った user を使って ViewModel を初期化
        _profileEditViewModel = State(initialValue: ProfileEditViewModel(user: user))
    }
    
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
                                if let uiImage = profileEditViewModel.favoriteCoffeeImage {
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
                                PhotosPicker(selection: $profileEditViewModel.selectedCoffeeItem, matching: .images) {
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
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .offset(y: profileSize * 0.5) // 💡 突き出し量を調整
                            .overlay(
                                PhotosPicker(selection: $profileEditViewModel.selectedProfileItem, matching: .images) {
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
                        VStack(alignment: .leading, spacing: 0) { // 💡間隔を0にして各field内のpaddingで調整
                            editField(label: "名前",
                                      text: $profileEditViewModel.userName,
                                      placeholder: "名前")
                            
                            editField(label: "自己紹介",
                                      text: $profileEditViewModel.selfIntroduction,
                                      placeholder: "自己紹介を入力してください",
                                      isMultiLine: true)
                            
                            Button(action: {
                                profileEditViewModel.isShowingAgePicker = true
                            }) {
                                HStack {
                                    Text("年齢")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(profileEditViewModel.userAge == 0 ? "選択してください" : "\(profileEditViewModel.userAge) 歳")
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 20)
                            // シートの定義
                            .sheet(isPresented: $profileEditViewModel.isShowingAgePicker) {
                                AgeSelectionView(ageSelectionViewModel: AgeSelectionViewModel())
                            }
                            Divider()
                            
                            Button(action: {
                                profileEditViewModel.isShowingPrefecturePicker = true
                            }) {
                                HStack {
                                    Text("出身地")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    // ViewModelの値を表示
                                    Text(profileEditViewModel.user.prefecture.isEmpty ? "選択してください" : profileEditViewModel.user.prefecture)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            // ProfileEditView.swift の該当箇所
                            .sheet(isPresented: $profileEditViewModel.isShowingPrefecturePicker) {
                                // 引数エラーが出ていた箇所を以下のように直す
                                PrefectureSelectionView { selectedValue in
                                    profileEditViewModel.prefecture = selectedValue
                                }
                            }
                            Divider()
                            
                            
                            Text("コーヒーの好み")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                                .padding(.leading, 0) // 必要に応じて調整
                            
                            editField(label: "国名", text: $profileEditViewModel.favoriteCoffee,placeholder: "好きな国")
                            ratingRow(label: "苦味", rating: $profileEditViewModel.probitter)
                            ratingRow(label: "酸味", rating: $profileEditViewModel.proacidity)
                            ratingRow(label: "コク", rating: $profileEditViewModel.probody)
                            ratingRow(label: "香り", rating: $profileEditViewModel.proaroma)
                            editField(label: "フレーバー", text: $profileEditViewModel.proflavor, placeholder: "好みのフレーバーがあれば教えてください")
                            Divider()
                            VStack(alignment: .leading, spacing: 25) {
                                
                                Text("お気に入りの道具")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 20)
                                    .padding(.bottom, 10)
                                    .padding(.leading, 0) // 必要に応じて調整
                                
                                // 1. ドリップ用品セクション
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("ドリップ用品")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.secondary)
                                    
                                    editField(label: "ドリッパー", text: $profileEditViewModel.dripper, placeholder: "ドリッパーを入力してください")
                                    editField(label: "ペーパーフィルター", text: $profileEditViewModel.paperFilter, placeholder: "ペーパーフィルターを入力してください")
                                    editField(label: "ケトル", text: $profileEditViewModel.kettle, placeholder: "ケトルを入力してください")
                                    editField(label: "サーバー", text: $profileEditViewModel.server, placeholder: "サーバーを入力してください")
                                    editField(label: "スケール", text: $profileEditViewModel.scale, placeholder: "スケールを入力してください")
                                }
                                
                                // 2. 粉砕器具セクション
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("粉砕器具（ミル・グラインダー）")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.secondary)
                                    
                                    editField(label: "ミル", text: $profileEditViewModel.mill, placeholder: "ミルを入力してください")
                                    editField(label: "グラインダー", text: $profileEditViewModel.grinder, placeholder: "グラインダーを入力してください")
                                }
                                
                                // 3. その他・エスプレッソセクション
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("その他")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.secondary)
                                    
                                    editField(label: "エスプレッソマシン", text: $profileEditViewModel.espressoMachine, placeholder: "エスプレッソマシンを入力してください")
                                    editField(label: "フレンチプレス", text: $profileEditViewModel.frenchPress, placeholder: "フレンチプレスを入力してください")
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 20)
                    .frame(width: screenWidth) // 💡 入力エリアの幅も画面幅に固定
                }
            }
            .navigationTitle("プロフィール編集")
            .onAppear {
                // すでに画像が読み込まれていなければ、URLからロードする
                if profileEditViewModel.profileImage == nil {
                    profileEditViewModel.loadProfileImageFromUrl()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // ProfileEditView の保存ボタン内
                    Button("保存") {
                        Task {
                            if let uid = Auth.auth().currentUser?.uid {
                                // 1. 画像アップロードと Firestore 更新
                                try? await profileEditViewModel.uploadProfileAndSave(uid: uid)
                                
                                // 2. 💡 ここで ViewModel の値を更新する（UI即時反映のため）
                                profileEditViewModel.user.profileImageUrl = profileEditViewModel.profileImageUrl
                                
                                dismiss()
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
                // 見出しラベル
                Text(label)
                    .font(.body)
                    .frame(width: 100, alignment: .leading)
                    .padding(.vertical, 12)
                
                // 入力欄
                if isMultiLine {
                    // 複数行の場合
                    TextField(placeholder, text: text, axis: .vertical)
                        .font(.body)
                        .lineLimit(3...6) // 3行〜6行
                        .padding(.vertical, 12)
                } else {
                    // 1行の場合
                    TextField(placeholder, text: text)
                        .font(.body)
                        .lineLimit(1) // 1行固定
                        .padding(.vertical, 12)
                }
            }
            
            Divider()
                .padding(.leading, 0) // 必要に応じてラベルの末尾から線を開始させるなら調整
        }
    }
    
    @ViewBuilder
    private func ratingRow(label: String, rating: Binding<Int>) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                // 1. 左側の見出し（ここを 100 に固定しているので、右側の開始位置が決まる）
                Text(label)
                    .font(.body)
                    .frame(width: 100, alignment: .leading)
                    .padding(.vertical, 12)
                
                // 2. 右側の解答エリア（全体を一つのHStackで包む）
                HStack(spacing: 8) { // 弱い・星・強い の間の微調整
                    Text("弱い")
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        ForEach(1...profileEditViewModel.maxRating, id: \.self) { number in
                            profileEditViewModel.image(for: number, rating: rating.wrappedValue)
                                .foregroundColor(number > rating.wrappedValue ? profileEditViewModel.offColor : profileEditViewModel.onColor)
                                .onTapGesture {
                                    rating.wrappedValue = number
                                }
                        }
                    }
                    
                    Text("強い")
                        .foregroundColor(.secondary)
                }
                .font(.body)
                .padding(.vertical, 12) // editFieldの文字の高さと揃える
                
                Spacer() // 右側を空ける
            }
            
            Divider()
        }
    }
}




