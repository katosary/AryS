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
    
    @State private var currentStep = 0
    @FocusState private var isFocused: Bool
    
    // イニシャライザでLogを受け取りViewModelを初期化
    init(post: Binding<Log>) {
        self._post = post
        self._editCoffeeLogViewModel = State(initialValue: EditCoffeeLogViewModel(log: post.wrappedValue))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // メインコンテンツ
                VStack(spacing: 0) {
                    TabView(selection: $currentStep) {
                        step1View().tag(0)
                        step2View().tag(1)
                        step3View().tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .background(Color(.systemGroupedBackground))
                 
                // 上部固定ヘッダーエリア（×ボタンと保存ボタン）
                HStack {
                    // ×ボタン
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                     
                    Spacer()
                     
                    // 「保存する」ボタン（Step 3 / 最後のステップの時だけ表示）
                    if currentStep == 2 {
                        Button(action: {
                            isFocused = false
                            
                            var updatedPost = post
                            updatedPost.shopName = editCoffeeLogViewModel.shopName.isEmpty ? "店舗名未入力" : editCoffeeLogViewModel.shopName
                            updatedPost.blend = editCoffeeLogViewModel.blend
                            updatedPost.countryName = editCoffeeLogViewModel.countryName.isEmpty ? "生産国未入力" : editCoffeeLogViewModel.countryName
                            updatedPost.farmName = editCoffeeLogViewModel.farmName
                            updatedPost.grade = editCoffeeLogViewModel.grade
                            updatedPost.roastLevel = editCoffeeLogViewModel.roastLevel
                            updatedPost.flavorrating = editCoffeeLogViewModel.aromarating
                            updatedPost.memo = editCoffeeLogViewModel.memo
                            updatedPost.bitternessrating = editCoffeeLogViewModel.bitternessrating
                            updatedPost.acidityrating = editCoffeeLogViewModel.acidityrating
                            updatedPost.bodyrating = editCoffeeLogViewModel.bodyrating
                            updatedPost.sweetnessrating = editCoffeeLogViewModel.sweetnessrating
                            updatedPost.flavorTags = editCoffeeLogViewModel.selectedAromas
                            
                            post = updatedPost
                            dismiss()
                            
                            editCoffeeLogViewModel.updateLog(targetPost: post) { success in
                                if !success {
                                    print("⚠️ サーバーへの保存に失敗")
                                }
                            }
                        }) {
                            Text("保存する")
                                .bold()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .zIndex(10)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: currentStep) { isFocused = false }
        }
    }
    
    // MARK: - Steps
    
    @ViewBuilder
    private func step1View() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("基本情報").font(.title2).bold().padding(.top, 80)
                
                editField(label: "店舗名", text: $editCoffeeLogViewModel.shopName, placeholder: "店舗名を入力")
                editField(label: "ブレンド名", text: $editCoffeeLogViewModel.blend, placeholder: "ブレンド名 / 銘柄名を入力")
                editField(label: "農園名", text: $editCoffeeLogViewModel.farmName, placeholder: "農園名を入力")
                editField(label: "グレード", text: $editCoffeeLogViewModel.grade, placeholder: "グレードを入力 (例: G1, AAなど)")
                
                Button(action: {
                    isFocused = false
                    editCoffeeLogViewModel.isShowingCountryPicker = true
                }) {
                    HStack {
                        Text("生産国").foregroundColor(.primary)
                        Spacer()
                        Text(editCoffeeLogViewModel.countryName.isEmpty ? "選択してください" : editCoffeeLogViewModel.countryName)
                            .foregroundColor(editCoffeeLogViewModel.countryName.isEmpty ? .secondary : .primary)
                    }
                }
                .sheet(isPresented: $editCoffeeLogViewModel.isShowingCountryPicker) {
                    CountrySelectionView { selectedCountry in
                        editCoffeeLogViewModel.countryName = selectedCountry
                    }
                }
                Divider()
                
                Button(action: {
                    isFocused = false
                    editCoffeeLogViewModel.isShowingRoastPicker = true
                }) {
                    HStack {
                        Text("焙煎度").foregroundColor(.primary)
                        Spacer()
                        Text(editCoffeeLogViewModel.roastLevel.isEmpty ? "選択してください" : editCoffeeLogViewModel.roastLevel)
                            .foregroundColor(editCoffeeLogViewModel.roastLevel.isEmpty ? .secondary : .primary)
                    }
                }
                .sheet(isPresented: $editCoffeeLogViewModel.isShowingRoastPicker) {
                    RoastSelectionView { selectedRoast in
                        editCoffeeLogViewModel.roastLevel = selectedRoast
                    }
                }
            }
            .padding(24)
        }
        .onTapGesture { isFocused = false }
    }
    
    @ViewBuilder
    private func step2View() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("味わいの評価").font(.title2).bold().padding(.top, 80)
                    
                    // 1. 評価項目（苦味、酸味、コク、甘味）
                    VStack(alignment: .leading, spacing: 16) {
                        ratingRow(label: "苦味", rating: $editCoffeeLogViewModel.bitternessrating)
                        ratingRow(label: "酸味", rating: $editCoffeeLogViewModel.acidityrating)
                        ratingRow(label: "コク", rating: $editCoffeeLogViewModel.bodyrating)
                        ratingRow(label: "甘味", rating: $editCoffeeLogViewModel.sweetnessrating)
                    }
                    
                    Divider()
                    
                    // 2. フレーバーの特徴
                    VStack(alignment: .leading, spacing: 12) {
                        ratingRow(label: "フレーバー", rating: $editCoffeeLogViewModel.aromarating)
                        Text("特徴を選択").font(.subheadline).bold()
                        
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
                                    Text(aroma)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(isSelected ? .white : .primary)
                                    Spacer()
                                    if isSelected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(14)
                                .background(isSelected ? Color.blue : Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Divider()
                    
                    // 3. 一言メモ
                    memoField(
                        label: "一言メモ（任意）",
                        text: $editCoffeeLogViewModel.memo,
                        placeholder: "例）１口目のインパクトがすごい！\n冷めると酸味が強くなる！\n次はアイスも！etc"
                    )
                    .id("MemoField")
                }
                .padding(24)
                .padding(.bottom, 40)
            }
            .onTapGesture { isFocused = false }
            .onChange(of: isFocused) {
                if isFocused {
                    withAnimation {
                        proxy.scrollTo("MemoField", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func step3View() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("編集内容の確認").font(.title2).bold().padding(.top, 80)
                
                CoffeeLogView(
                    log: Log(
                        id: post.id,
                        userId: post.userId,
                        shopName: editCoffeeLogViewModel.shopName.isEmpty ? "店舗名未入力" : editCoffeeLogViewModel.shopName,
                        blend: editCoffeeLogViewModel.blend,
                        countryName: editCoffeeLogViewModel.countryName.isEmpty ? "生産国未入力" : editCoffeeLogViewModel.countryName,
                        farmName: editCoffeeLogViewModel.farmName,
                        grade: editCoffeeLogViewModel.grade,
                        roastLevel: editCoffeeLogViewModel.roastLevel,
                        flavorrating: editCoffeeLogViewModel.aromarating,
                        memo: editCoffeeLogViewModel.memo,
                        bitternessrating: editCoffeeLogViewModel.bitternessrating,
                        acidityrating: editCoffeeLogViewModel.acidityrating,
                        bodyrating: editCoffeeLogViewModel.bodyrating,
                        sweetnessrating: editCoffeeLogViewModel.sweetnessrating,
                        flavorTags: editCoffeeLogViewModel.selectedAromas, 
                        createdAt: post.createdAt,
                        tagX: post.tagX,
                        tagY: post.tagY,
                        imageUrl: post.imageUrl,
                        previewImage: post.previewImage
                    ),
                    author: nil,
                    authorName: "あなた",
                    isEditable: false,
                    onTapMenu: {},
                    onTapLike: {},
                    onTapBookmark: {},
                    onTapProfile: {}
                )
                .cornerRadius(16)
                .shadow(radius: 4)
            }
            .padding(24)
        }
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func ratingRow(label: String, rating: Binding<Int>) -> some View {
        HStack {
            Text(label).frame(width: 80, alignment: .leading)
            Spacer()
            ForEach(1...editCoffeeLogViewModel.maxRating, id: \.self) { n in
                let isSelected = n <= rating.wrappedValue
                Image(isSelected ? "coffeeBeanFill" : "coffeeBean")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .contentShape(Rectangle())
                    .onTapGesture { rating.wrappedValue = n }
            }
        }
    }
    
    @ViewBuilder
    private func memoField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.top, 10)

            TextEditor(text: text)
                .frame(height: 100)
                .padding(4)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .focused($isFocused)
                .overlay(
                    Group {
                        if text.wrappedValue.isEmpty {
                            Text(placeholder)
                                .font(.body)
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }, alignment: .topLeading
                )
        }
    }
    
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack {
            HStack {
                Text(label).frame(width: 80)
                TextField(placeholder, text: text).focused($isFocused)
            }
            Divider()
        }
    }
}
