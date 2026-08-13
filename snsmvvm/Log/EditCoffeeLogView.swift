//
//  EditSheetView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/16.
//

import SwiftUI
import FirebaseAuth

struct PostEditView: View {
    @State private var editCoffeeLogViewModel: EditCoffeeLogViewModel
    let post: Log
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 1 // カメラがないためStep 1からスタート
    @State private var maxUnlockedStep = 4 // 編集時は全ステップを解放状態にする
    
    // イニシャライザでLogを受け取りViewModelを初期化
    init(post: Log) {
        self.post = post
        _editCoffeeLogViewModel = State(initialValue: EditCoffeeLogViewModel(log: post))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    
                    // --- Step 1: 基本情報 ---
                    ScrollView {
                        VStack {
                            Spacer(minLength: 0)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                stepHeader(title: "Step 1: 基本情報", isComplete: isStep1Complete())
                                
                                editField(label: "店舗名", text: $editCoffeeLogViewModel.shopName, placeholder: "店舗名を入力")
                                editField(label: "農園名", text: $editCoffeeLogViewModel.farmName, placeholder: "農園名を入力")
                                
                                Button(action: {
                                    editCoffeeLogViewModel.isShowingCountryPicker = true
                                }) {
                                    HStack {
                                        Text("生産国").foregroundColor(.primary)
                                        Spacer()
                                        Text(editCoffeeLogViewModel.countryName.isEmpty ? "選択してください" : editCoffeeLogViewModel.countryName)
                                            .foregroundColor(editCoffeeLogViewModel.countryName.isEmpty ? .secondary : .primary)
                                        Image(systemName: "chevron.right").foregroundColor(.gray)
                                    }
                                }
                                .sheet(isPresented: $editCoffeeLogViewModel.isShowingCountryPicker) {
                                    CountrySelectionView { selectedCountry in
                                        editCoffeeLogViewModel.countryName = selectedCountry
                                    }
                                }
                                Divider()
                                
                                Button(action: {
                                    editCoffeeLogViewModel.isShowingRoastPicker = true
                                }) {
                                    HStack {
                                        Text("焙煎度").foregroundColor(.primary)
                                        Spacer()
                                        Text(editCoffeeLogViewModel.roastLevel.isEmpty ? "選択してください" : editCoffeeLogViewModel.roastLevel)
                                            .foregroundColor(editCoffeeLogViewModel.roastLevel.isEmpty ? .secondary : .primary)
                                        Image(systemName: "chevron.right").foregroundColor(.gray)
                                    }
                                }
                                .sheet(isPresented: $editCoffeeLogViewModel.isShowingRoastPicker) {
                                    RoastSelectionView { selectedRoast in
                                        editCoffeeLogViewModel.roastLevel = selectedRoast
                                    }
                                }
                            }
                            .padding(24)
                            
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 500)
                    }
                    .tag(1)
                    
                    // --- Step 2: 香り ---
                    ScrollView {
                        VStack {
                            Spacer(minLength: 0)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                stepHeader(title: "Step 2: 香りの評価", isComplete: isStep2Complete())
                                
                                HStack {
                                    Text("強さ").frame(width: 50, alignment: .leading)
                                    Spacer()
                                    ForEach(1...editCoffeeLogViewModel.maxRating, id: \.self) { number in
                                        editCoffeeLogViewModel.image(for: number, rating: editCoffeeLogViewModel.aromarating)
                                            .font(.system(size: 26))
                                            .foregroundColor(number > editCoffeeLogViewModel.aromarating ? editCoffeeLogViewModel.offColor : editCoffeeLogViewModel.onColor)
                                            .onTapGesture {
                                                editCoffeeLogViewModel.aromarating = number
                                            }
                                    }
                                }
                                
                                TextField("どんな香りでしたか？", text: $editCoffeeLogViewModel.aromaComment)
                                    .textFieldStyle(.roundedBorder)
                            }
                            .padding(24)
                            
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 500)
                    }
                    .tag(2)
                    
                    // --- Step 3: 味わい評価 ---
                    ScrollView {
                        VStack {
                            Spacer(minLength: 0)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                stepHeader(title: "Step 3: 味わいの評価", isComplete: isStep3Complete())
                                
                                VStack(spacing: 16) {
                                    ratingRow(label: "苦味", rating: $editCoffeeLogViewModel.bitternessrating)
                                    ratingRow(label: "酸味", rating: $editCoffeeLogViewModel.acidityrating)
                                    ratingRow(label: "コク", rating: $editCoffeeLogViewModel.bodyrating)
                                }
                            }
                            .padding(24)
                            
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 500)
                    }
                    .tag(3)
                    
                    // --- Step 4: 投稿プレビュー & 保存 ---
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                stepHeader(title: "Step 4: 編集内容の確認", isComplete: false)

                                Button {
                                    editCoffeeLogViewModel.updateLog(targetPost: post) { success in
                                        if success { dismiss() }
                                    }
                                } label: {
                                    Text("保存する")
                                        .bold()
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 10)
                            }
                            
                            let previewLog = Log(
                                id: post.id,
                                userId: post.userId,
                                shopName: editCoffeeLogViewModel.shopName.isEmpty ? "店舗名未入力" : editCoffeeLogViewModel.shopName,
                                countryName: editCoffeeLogViewModel.countryName.isEmpty ? "生産国未入力" : editCoffeeLogViewModel.countryName,
                                farmName: editCoffeeLogViewModel.farmName,
                                roastLevel: editCoffeeLogViewModel.roastLevel,
                                aromarating: editCoffeeLogViewModel.aromarating,
                                aromaComment: editCoffeeLogViewModel.aromaComment,
                                bitternessrating: editCoffeeLogViewModel.bitternessrating,
                                acidityrating: editCoffeeLogViewModel.acidityrating,
                                bodyrating: editCoffeeLogViewModel.bodyrating,
                                createdAt: post.createdAt,
                                tagX: post.tagX,
                                tagY: post.tagY,
                                imageUrl: post.imageUrl,
                                previewImage: post.previewImage
                            )
                            
                            CoffeeLogView(
                                log: previewLog,
                                author: nil,
                                authorName: "あなた",
                                onLike: {},
                                isEditable: false,
                                isSaved: false,
                                onSave: {},
                                onDelete: {},
                                onEdit: {}
                            )
                            .cornerRadius(16)
                            .shadow(radius: 4)
                        }
                        .padding(24)
                    }
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("投稿を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - 各ステップの完了判定ロジック
    private func isStep1Complete() -> Bool {
        return !editCoffeeLogViewModel.shopName.isEmpty &&
               !editCoffeeLogViewModel.countryName.isEmpty &&
               !editCoffeeLogViewModel.roastLevel.isEmpty
    }
    
    private func isStep2Complete() -> Bool {
        return editCoffeeLogViewModel.aromarating > 0
    }
    
    private func isStep3Complete() -> Bool {
        return editCoffeeLogViewModel.bitternessrating > 0 ||
               editCoffeeLogViewModel.acidityrating > 0 ||
               editCoffeeLogViewModel.bodyrating > 0
    }
    
    // MARK: - UI パーツ
    @ViewBuilder
    private func stepHeader(title: String, isComplete: Bool) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .bold()
            Spacer()
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
    
    @ViewBuilder
    private func ratingRow(label: String, rating: Binding<Int>) -> some View {
        HStack {
            Text(label).frame(width: 50, alignment: .leading)
            Spacer()
            ForEach(1...editCoffeeLogViewModel.maxRating, id: \.self) { number in
                editCoffeeLogViewModel.image(for: number, rating: rating.wrappedValue)
                    .font(.system(size: 26))
                    .foregroundColor(number > rating.wrappedValue ? editCoffeeLogViewModel.offColor : editCoffeeLogViewModel.onColor)
                    .onTapGesture {
                        rating.wrappedValue = number
                    }
            }
        }
    }
    
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Text(label).frame(width: 80, alignment: .leading)
            TextField(placeholder, text: text)
        }
        .padding(.vertical, 4)
        Divider()
    }
}


