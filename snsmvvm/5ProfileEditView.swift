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
    @Environment(ViewModel.self) var viewModel
    var profileViewModel: ProfileViewModel
    
    let coverHeight: CGFloat = 200 // 編集時は少し低めが見やすい
    let profileSize: CGFloat = 100
    
    var body: some View {
        @Bindable var profileViewModel = profileViewModel
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
                        VStack(alignment: .leading, spacing: 0) { // 💡間隔を0にして各field内のpaddingで調整
                            editField(label: "名前",
                                      text: $profileViewModel.userName,
                                      placeholder: "名前")
                            
                            editField(label: "自己紹介",
                                      text: $profileViewModel.selfIntroduction,
                                      placeholder: "自己紹介を入力してください",
                                      isMultiLine: true)
                            
                            Button(action: {
                                profileViewModel.isShowingAgePicker = true
                            }) {
                                HStack {
                                    Text("年齢")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(profileViewModel.userAge == 0 ? "選択してください" : "\(profileViewModel.userAge) 歳")
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 20)
                            // シートの定義
                            .sheet(isPresented: $profileViewModel.isShowingAgePicker) {
                                AgeSelectionView(profileViewModel: profileViewModel)
                            }
                            Divider()
                            
                            Button(action: {
                                profileViewModel.isShowingBirthPlacePicker = true
                            }) {
                                HStack {
                                    Text("出身地")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(profileViewModel.birthPlace.isEmpty ? "選択してください" : profileViewModel.birthPlace)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 20)
                            // シートの定義
                            .sheet(isPresented: $profileViewModel.isShowingBirthPlacePicker) {
                                PrefectureSelectionView(profileViewModel: profileViewModel)
                            }
                            Divider()
                            
                            
                            Text("コーヒーの好み")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                                .padding(.leading, 0) // 必要に応じて調整
                            
                            editField(label: "国名", text: $profileViewModel.favoriteCoffee,placeholder: "好きな国")
                            ratingRow(label: "苦味", rating: $profileViewModel.probitter)
                            ratingRow(label: "酸味", rating: $profileViewModel.proacidity)
                            ratingRow(label: "コク", rating: $profileViewModel.probody)
                            ratingRow(label: "香り", rating: $profileViewModel.proaroma)
                            editField(label: "フレーバー", text: $profileViewModel.proflavor, placeholder: "好みのフレーバーがあれば教えてください")
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
                                        
                                        editField(label: "ドリッパー", text: $profileViewModel.dripper, placeholder: "ドリッパーを入力してください")
                                        editField(label: "ペーパーフィルター", text: $profileViewModel.paperFilter, placeholder: "ペーパーフィルターを入力してください")
                                        editField(label: "ケトル", text: $profileViewModel.kettle, placeholder: "ケトルを入力してください")
                                        editField(label: "サーバー", text: $profileViewModel.server, placeholder: "サーバーを入力してください")
                                        editField(label: "スケール", text: $profileViewModel.scale, placeholder: "スケールを入力してください")
                                    }
                                    
                                    // 2. 粉砕器具セクション
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("粉砕器具（ミル・グラインダー）")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.secondary)
                                        
                                        editField(label: "ミル", text: $profileViewModel.mill, placeholder: "ミルを入力してください")
                                        editField(label: "グラインダー", text: $profileViewModel.grinder, placeholder: "グラインダーを入力してください")
                                    }
                                    
                                    // 3. その他・エスプレッソセクション
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("その他")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.secondary)
                                        
                                        editField(label: "エスプレッソマシン", text: $profileViewModel.espressoMachine, placeholder: "エスプレッソマシンを入力してください")
                                        editField(label: "フレンチプレス", text: $profileViewModel.frenchPress, placeholder: "フレンチプレスを入力してください")
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        profileViewModel.updateUser(viewModel: viewModel)
                        dismiss()
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
                        ForEach(1...profileViewModel.maxRating, id: \.self) { number in
                            profileViewModel.image(for: number, rating: rating.wrappedValue)
                                .foregroundColor(number > rating.wrappedValue ? profileViewModel.offColor : profileViewModel.onColor)
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

struct AgeSelectionView: View {
    // @ObservableなViewModelを双方向バインディング可能にするために @Bindable を使用
    @Environment(ViewModel.self) var viewModel
    @Bindable var profileViewModel: ProfileViewModel
    
    // シートを閉じるための環境変数
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                // ドラムロール形式のピッカー
                Picker("年齢", selection: $profileViewModel.userAge) {
                    ForEach(profileViewModel.ages, id: \.self) { age in
                        // ageは数値なので、文字列に変換して表示
                        Text("\(age) 歳").tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden() // 余計なラベルを消して中央に配置
                
                Text("選択中の年齢: \(profileViewModel.userAge) 歳")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .navigationTitle("年齢を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        // ユーザー情報を更新してから閉じる
                        profileViewModel.updateUser(viewModel: viewModel)
                        dismiss()
                    }
                }
            }
        }
        // ハーフモーダルとして表示（iOS 16.0+）
        .presentationDetents([.height(300)])
        // ドラッグで閉じられないようにする場合は以下（任意）
        // .interactiveDismissDisabled()
    }
}

struct PrefectureSelectionView: View {
    // ViewModelを双方向バインディング可能にする
    @Environment(ViewModel.self) var viewModel
    @Bindable var profileViewModel: ProfileViewModel
    
    // シートを閉じるための環境変数
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                // ドラムロール形式のピッカー
                Picker("都道府県", selection: $profileViewModel.birthPlace) {
                    ForEach(profileViewModel.prefectures, id: \.self) { pref in
                        // pref は「東京都」などの文字列。そのまま表示し、tagにも文字列を渡す
                        Text(pref).tag(pref)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden() // 中央に配置
                
                Text("選択中: \(profileViewModel.birthPlace.isEmpty ? "未選択" : profileViewModel.birthPlace)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .navigationTitle("都道府県を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        profileViewModel.updateUser(viewModel: viewModel) // 必要に応じて更新処理
                        dismiss()
                    }
                }
            }
        }
        // 年齢と同じくハーフモーダルで表示
        .presentationDetents([.height(300)])
    }
}

