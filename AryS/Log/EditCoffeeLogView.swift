//
//  PostEditView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/16.
//

import SwiftUI
import FirebaseAuth
import UIKit

struct PostEditView: View {
    @State private var editCoffeeLogViewModel: EditCoffeeLogViewModel
    @Binding var post: Log
    var onUpdate: ((Log) -> Void)? = nil // 💡 追加: 編集完了を親に即時通知するためのクロージャー
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @FocusState private var isFocused: Bool
    
    init(post: Binding<Log>, onUpdate: ((Log) -> Void)? = nil) {
        self._post = post
        self.onUpdate = onUpdate
        self._editCoffeeLogViewModel = State(initialValue: EditCoffeeLogViewModel(log: post.wrappedValue))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Group {
                        switch currentStep {
                        case 0: step1View()
                        case 1: step2View()
                        case 2: step3View()
                        default: step1View()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color(.systemGroupedBackground))
                 
                // ヘッダー（戻る/×ボタン と 次へ/保存するボタン）
                HStack(spacing: 12) {
                    if currentStep == 0 {
                        Button(action: {
                            triggerHaptic(style: .light)
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                    } else {
                        Button(action: {
                            triggerHaptic(style: .light)
                            isFocused = false
                            withAnimation { currentStep -= 1 }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                    }
                     
                    Spacer()
                     
                    if currentStep == 0 {
                        Button(action: {
                            triggerHaptic(style: .medium)
                            withAnimation { currentStep = 1 }
                        }) {
                            nextButtonLabel(text: "次へ")
                        }
                    }
                     
                    if currentStep == 1 {
                        Button(action: {
                            triggerHaptic(style: .medium)
                            isFocused = false
                            withAnimation { currentStep = 2 }
                        }) {
                            nextButtonLabel(text: "次へ")
                        }
                    }

                    if currentStep == 2 {
                        Button(action: {
                            triggerHaptic(style: .heavy)
                            isFocused = false
                             
                            editCoffeeLogViewModel.updateLog(targetPost: $post.wrappedValue) { success in
                                if success {
                                    // 💡 1. 編集された最新のLogオブジェクトを生成する
                                    let updatedLog = editCoffeeLogViewModel.makeUpdatedLog(from: $post.wrappedValue)
                                     
                                    // 💡 2. Binding元を更新する
                                    $post.wrappedValue = updatedLog
                                     
                                    // 💡 3. 親ビュー（TimeLineViewModelなど）に即時通知する
                                    onUpdate?(updatedLog)
                                     
                                    // 💡 4. 編集画面を閉じる
                                    dismiss()
                                } else {
                                    print("⚠️ サーバーへの保存に失敗")
                                }
                            }
                        }) {
                            nextButtonLabel(text: "保存する")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .zIndex(10)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: currentStep) { _, _ in isFocused = false }
        }
    }
     
    @ViewBuilder
    private func nextButtonLabel(text: String) -> some View {
        Text(text)
            .bold()
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
    }
     
    // MARK: - Steps
     
    @ViewBuilder
    private func step1View() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("基本情報").font(.title2).bold().padding(.top, 80)
                 
                // 1. 店舗名
                editField(label: "店舗名（必須）", text: $editCoffeeLogViewModel.shopName, placeholder: "店舗名を入力")
                 
                // 2. 豆の種類 (isBlendによる切り替え)
                VStack(alignment: .leading, spacing: 8) {
                    Text("豆の種類").font(.subheadline).foregroundColor(.secondary)
                    Picker("豆の種類", selection: $editCoffeeLogViewModel.isBlend) {
                        Text("シングルオリジン").tag(false)
                        Text("ブレンド").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                 
                // 3. タイプに応じた動的フォーム
                if editCoffeeLogViewModel.isBlend {
                    // --- ブレンドの場合 ---
                    editField(label: "ブレンド名（必須）", text: $editCoffeeLogViewModel.blend, placeholder: "ブレンド名を入力")
                     
                    VStack(alignment: .leading, spacing: 8) {
                        Text("含まれている国（含有率の多い国から）")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                         
                        blendCountryPickerButton(label: "国 1", country: editCoffeeLogViewModel.blendCountry1) {
                            editCoffeeLogViewModel.activeCountryTarget = .blend1
                            editCoffeeLogViewModel.isShowingCountryPicker = true
                        }
                        blendCountryPickerButton(label: "国 2", country: editCoffeeLogViewModel.blendCountry2) {
                            editCoffeeLogViewModel.activeCountryTarget = .blend2
                            editCoffeeLogViewModel.isShowingCountryPicker = true
                        }
                        blendCountryPickerButton(label: "国 3", country: editCoffeeLogViewModel.blendCountry3) {
                            editCoffeeLogViewModel.activeCountryTarget = .blend3
                            editCoffeeLogViewModel.isShowingCountryPicker = true
                        }
                    }
                } else {
                    // --- シングルオリジンの場合 ---
                    Button(action: {
                        isFocused = false
                        editCoffeeLogViewModel.activeCountryTarget = .single
                        editCoffeeLogViewModel.isShowingCountryPicker = true
                    }) {
                        HStack {
                            Text("生産国（必須）")
                                .frame(width: 130, alignment: .leading)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(editCoffeeLogViewModel.countryName.isEmpty ? "選択してください" : editCoffeeLogViewModel.countryName)
                                .foregroundColor(editCoffeeLogViewModel.countryName.isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                    }
                    Divider()
                     
                    editField(label: "銘柄 / 品種", text: $editCoffeeLogViewModel.blend, placeholder: "銘柄名を入力")
                    editField(label: "農園名", text: $editCoffeeLogViewModel.farmName, placeholder: "農園名を入力")
                    editField(label: "グレード", text: $editCoffeeLogViewModel.grade, placeholder: "例: G1, AAなど")
                     
                    // 4. 焙煎度（シングルオリジンのみ）
                    Button(action: {
                        isFocused = false
                        editCoffeeLogViewModel.isShowingRoastPicker = true
                    }) {
                        HStack {
                            Text("焙煎度（必須）")
                                .frame(width: 130, alignment: .leading)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(editCoffeeLogViewModel.roastLevel.isEmpty ? "選択してください" : editCoffeeLogViewModel.roastLevel)
                                .foregroundColor(editCoffeeLogViewModel.roastLevel.isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                    }
                    .sheet(isPresented: $editCoffeeLogViewModel.isShowingRoastPicker) {
                        RoastSelectionView { editCoffeeLogViewModel.roastLevel = $0 }
                    }
                    Divider()
                }
            }
            .padding(24)
        }
        .sheet(isPresented: $editCoffeeLogViewModel.isShowingCountryPicker) {
            CountrySelectionView { selectedCountry in
                switch editCoffeeLogViewModel.activeCountryTarget {
                case .single:
                    editCoffeeLogViewModel.countryName = selectedCountry
                case .blend1:
                    editCoffeeLogViewModel.blendCountry1 = selectedCountry
                case .blend2:
                    editCoffeeLogViewModel.blendCountry2 = selectedCountry
                case .blend3:
                    editCoffeeLogViewModel.blendCountry3 = selectedCountry
                }
            }
        }
        .onTapGesture { isFocused = false }
    }
     
    @ViewBuilder
    private func step2View() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("味わいの評価").font(.title2).bold().padding(.top, 80)
                     
                    VStack(alignment: .leading, spacing: 16) {
                        ratingRow(label: "苦味", rating: $editCoffeeLogViewModel.bitternessrating)
                        ratingRow(label: "酸味", rating: $editCoffeeLogViewModel.acidityrating)
                        ratingRow(label: "コク", rating: $editCoffeeLogViewModel.bodyrating)
                        ratingRow(label: "甘味", rating: $editCoffeeLogViewModel.sweetnessrating)
                    }
                     
                    Divider()
                     
                    VStack(alignment: .leading, spacing: 12) {
                        ratingRow(label: "フレーバー", rating: $editCoffeeLogViewModel.flavorrating)
                        Text("特徴を1つ選択").font(.subheadline).bold()
                         
                        ForEach(editCoffeeLogViewModel.flavorOptions, id: \.self) { aroma in
                            let isSelected = editCoffeeLogViewModel.selectedAroma == aroma
                            Button(action: {
                                triggerHaptic(style: .light)
                                withAnimation {
                                    editCoffeeLogViewModel.selectedAroma = isSelected ? "" : aroma
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
            .onChange(of: isFocused) { _, focused in
                if focused {
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
            VStack(spacing: 16) {
                Text("編集内容の確認")
                    .font(.title2)
                    .bold()
                    .padding(.top, 50)
                 
                CoffeeLogView(
                    log: Log(
                        id: post.id,
                        userId: post.userId,
                        shopName: editCoffeeLogViewModel.shopName.isEmpty ? "店舗名未入力" : editCoffeeLogViewModel.shopName,
                        blend: editCoffeeLogViewModel.blend,
                        countryName: editCoffeeLogViewModel.isBlend ? editCoffeeLogViewModel.blendCountry1 : editCoffeeLogViewModel.countryName,
                        farmName: editCoffeeLogViewModel.farmName,
                        grade: editCoffeeLogViewModel.grade,
                        roastLevel: editCoffeeLogViewModel.isBlend ? "" : editCoffeeLogViewModel.roastLevel,
                        flavorrating: editCoffeeLogViewModel.flavorrating,
                        memo: editCoffeeLogViewModel.memo,
                        bitternessrating: editCoffeeLogViewModel.bitternessrating,
                        acidityrating: editCoffeeLogViewModel.acidityrating,
                        bodyrating: editCoffeeLogViewModel.bodyrating,
                        sweetnessrating: editCoffeeLogViewModel.sweetnessrating,
                        flavorTags: editCoffeeLogViewModel.selectedAroma.isEmpty ? [] : [editCoffeeLogViewModel.selectedAroma],
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
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
     
    // MARK: - Helpers
     
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
     
    @ViewBuilder
    private func blendCountryPickerButton(label: String, country: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            isFocused = false
            action()
        }) {
            HStack {
                Text(label)
                    .frame(width: 60, alignment: .leading)
                    .foregroundColor(.primary)
                Spacer()
                Text(country.isEmpty ? "選択してください" : country)
                    .foregroundColor(country.isEmpty ? .secondary : .primary)
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
     
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
                    .onTapGesture {
                        triggerHaptic(style: .light)
                        rating.wrappedValue = n
                    }
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
                Text(label).frame(width: 130, alignment: .leading)
                TextField(placeholder, text: text).focused($isFocused)
            }
            Divider()
        }
    }
}
