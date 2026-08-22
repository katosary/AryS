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
    @Binding var post: Log
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 1
    @State private var maxUnlockedStep = 3
    @State private var isFocused: Bool = false
    
    // イニシャライザでLogを受け取りViewModelを初期化
    init(post: Binding<Log>) {
        self._post = post
        self._editCoffeeLogViewModel = State(initialValue: EditCoffeeLogViewModel(log: post.wrappedValue))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    step1View.tag(1)
                    aromaAndTasteStepView.tag(2)
                    step4View.tag(3)
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
    
    // MARK: - 各ステップのビュー分割
    
    @ViewBuilder
    private var step1View: some View {
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
        .onTapGesture {
            isFocused = false
        }
    }
    
    @ViewBuilder
        private var aromaAndTasteStepView: some View {
            ScrollView {
                VStack {
                    Spacer(minLength: 0)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        stepHeader(title: "Step 2: フレーバーと味わい", isComplete: isStep2Complete())
                        
                        // --- フレーバーの評価 ---
                        VStack(alignment: .leading, spacing: 12) {
                            Text("フレーバーの評価").font(.subheadline).bold()
                            ratingRow(label: "強さ", rating: $editCoffeeLogViewModel.aromarating)
                            
                            Text("特徴を選択").font(.caption).foregroundColor(.secondary)
                            
                            // 💡 修正: CoffeeRecordView と完全に同じロジックとデザインに変更
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(editCoffeeLogViewModel.flavorOptions, id: \.self) { aroma in
                                    let isSelected = editCoffeeLogViewModel.selectedAromas.contains(aroma)
                                    Button(action: {
                                        withAnimation {
                                            if isSelected {
                                                editCoffeeLogViewModel.selectedAromas.removeAll { $0 == aroma }
                                            } else {
                                                editCoffeeLogViewModel.selectedAromas.append(aroma)
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Text(aroma) // カッコ付きの文字列をそのまま表示
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(isSelected ? .white : .primary)
                                            Spacer()
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .background(isSelected ? Color.blue : Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // --- 味わいの評価 ---
                        VStack(alignment: .leading, spacing: 16) {
                            Text("味わいの評価").font(.subheadline).bold()
                            
                            ratingRow(label: "苦味", rating: $editCoffeeLogViewModel.bitternessrating)
                            ratingRow(label: "酸味", rating: $editCoffeeLogViewModel.acidityrating)
                            ratingRow(label: "コク", rating: $editCoffeeLogViewModel.bodyrating)
                        }
                        
                        Divider()
                        
                        // --- 一言メモ ---
                        memoField(
                            label: "一言メモ",
                            text: $editCoffeeLogViewModel.memo,
                            placeholder: "例）１口目のインパクトがすごい！\n冷めると酸味が強くなる！\n次はアイスも！etc"
                        )
                    }
                    .padding(24)
                    
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, minHeight: 500)
            }
            .onTapGesture {
                isFocused = false
            }
        }
    
    @ViewBuilder
    private var step4View: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    stepHeader(title: "Step 3: 編集内容の確認", isComplete: false)
                    
                    Button {
                        var updatedPost = post
                        updatedPost.shopName = editCoffeeLogViewModel.shopName.isEmpty ? "店舗名未入力" : editCoffeeLogViewModel.shopName
                        updatedPost.countryName = editCoffeeLogViewModel.countryName.isEmpty ? "生産国未入力" : editCoffeeLogViewModel.countryName
                        updatedPost.farmName = editCoffeeLogViewModel.farmName
                        updatedPost.roastLevel = editCoffeeLogViewModel.roastLevel
                        updatedPost.aromarating = editCoffeeLogViewModel.aromarating
                        updatedPost.aromaComment = editCoffeeLogViewModel.memo
                        updatedPost.bitternessrating = editCoffeeLogViewModel.bitternessrating
                        updatedPost.acidityrating = editCoffeeLogViewModel.acidityrating
                        updatedPost.bodyrating = editCoffeeLogViewModel.bodyrating
                        updatedPost.aromaTags = editCoffeeLogViewModel.selectedAromas
                        
                        post = updatedPost
                        dismiss()
                        
                        editCoffeeLogViewModel.updateLog(targetPost: post) { success in
                            if !success {
                                print("⚠️ サーバーへの保存に失敗")
                            }
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
                
                CoffeeLogView(
                    log: Log(
                        id: post.id,
                        userId: post.userId,
                        shopName: editCoffeeLogViewModel.shopName.isEmpty ? "店舗名未入力" : editCoffeeLogViewModel.shopName,
                        countryName: editCoffeeLogViewModel.countryName.isEmpty ? "生産国未入力" : editCoffeeLogViewModel.countryName,
                        farmName: editCoffeeLogViewModel.farmName,
                        roastLevel: editCoffeeLogViewModel.roastLevel,
                        aromarating: editCoffeeLogViewModel.aromarating,
                        aromaComment: editCoffeeLogViewModel.memo,
                        bitternessrating: editCoffeeLogViewModel.bitternessrating,
                        acidityrating: editCoffeeLogViewModel.acidityrating,
                        bodyrating: editCoffeeLogViewModel.bodyrating,
                        aromaTags: editCoffeeLogViewModel.selectedAromas,
                        createdAt: post.createdAt,
                        tagX: post.tagX,
                        tagY: post.tagY,
                        imageUrl: post.imageUrl,
                        previewImage: post.previewImage
                    ),
                    author: nil,
                    authorName: "あなた",
                    isEditable: false
                )
                .cornerRadius(16)
                .shadow(radius: 4)
            }
            .padding(24)
        }
        .onTapGesture {
            isFocused = false
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
                let isSelected = number <= rating.wrappedValue
                
                Image(isSelected ? "coffeeBeanFill" : "coffeeBean")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(isSelected ? editCoffeeLogViewModel.onColor : editCoffeeLogViewModel.offColor)
                    .contentShape(Rectangle())
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
    
    @ViewBuilder
    private func memoField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.top, 10)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 100)
                
                TextEditor(text: text)
                    .frame(height: 100)
                    .padding(4)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.body)
                        .foregroundColor(Color(.placeholderText))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}
