//
//  CoffeeRecordView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import SwiftUI
import FirebaseAuth
import PhotosUI
import UIKit

struct CoffeeRecordView: View {
    @State var coffeeRecordViewModel = CoffeeRecordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var shouldCapture = false
    @State private var isShowingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    @FocusState private var isFocused: Bool
    
    var onDismiss: (() -> Void)?
    var onCompleted: (() -> Void)?
    
    // 基本情報の必須チェック（シングルオリジンは焙煎度も必須、ブレンドは店舗名・ブレンド名のみ必須）
    private var isBasicInfoValid: Bool {
        let isShopValid = !coffeeRecordViewModel.shopName.trimmingCharacters(in: .whitespaces).isEmpty
        
        if coffeeRecordViewModel.isBlend {
            let isBlendNameValid = !coffeeRecordViewModel.blend.trimmingCharacters(in: .whitespaces).isEmpty
            return isShopValid && isBlendNameValid
        } else {
            let isCountryValid = !coffeeRecordViewModel.countryName.isEmpty
            let isRoastValid = !coffeeRecordViewModel.roastLevel.isEmpty
            return isShopValid && isCountryValid && isRoastValid
        }
    }
    
    // 味わいの評価の必須チェック
    private var isTasteValid: Bool {
        coffeeRecordViewModel.bitternessrating > 0 &&
        coffeeRecordViewModel.acidityrating > 0 &&
        coffeeRecordViewModel.bodyrating > 0 &&
        coffeeRecordViewModel.sweetnessrating > 0 &&
        coffeeRecordViewModel.flavorrating > 0 &&
        !coffeeRecordViewModel.selectedAroma.isEmpty
    }
    
    private var previewLog: Log {
            let finalCountryName: String
            if coffeeRecordViewModel.isBlend {
                let countries = [coffeeRecordViewModel.blendCountry1, coffeeRecordViewModel.blendCountry2, coffeeRecordViewModel.blendCountry3].filter { !$0.isEmpty }
                finalCountryName = countries.joined(separator: ", ")
            } else {
                finalCountryName = coffeeRecordViewModel.countryName.isEmpty ? "生産国未入力" : coffeeRecordViewModel.countryName
            }
             
            return Log(
                id: nil,
                userId: Auth.auth().currentUser?.uid ?? "",
                shopName: coffeeRecordViewModel.shopName.isEmpty ? "店舗名未入力" : coffeeRecordViewModel.shopName,
                blend: coffeeRecordViewModel.blend,
                countryName: finalCountryName,
                farmName: coffeeRecordViewModel.isBlend ? "" : coffeeRecordViewModel.farmName,
                grade: coffeeRecordViewModel.isBlend ? "" : coffeeRecordViewModel.grade,
                // 変更：ブレンドの場合は焙煎度を空文字にする
                roastLevel: coffeeRecordViewModel.isBlend ? "" : coffeeRecordViewModel.roastLevel,
                flavorrating: coffeeRecordViewModel.flavorrating,
                memo: coffeeRecordViewModel.memo,
                bitternessrating: coffeeRecordViewModel.bitternessrating,
                acidityrating: coffeeRecordViewModel.acidityrating,
                bodyrating: coffeeRecordViewModel.bodyrating,
                sweetnessrating: coffeeRecordViewModel.sweetnessrating,
                flavorTags: coffeeRecordViewModel.selectedAroma.isEmpty ? [] : [coffeeRecordViewModel.selectedAroma],
                createdAt: Date(),
                tagX: 0.0,
                tagY: 0.0,
                imageUrl: nil,
                previewImage: coffeeRecordViewModel.logImages.first
            )
        }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Group {
                        switch currentStep {
                        case 0: cameraStepView()
                        case 1: basicInfoStepView()
                        case 2: tasteStepView()
                        case 3: previewStepView()
                        default: cameraStepView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color(.systemGroupedBackground))
                 
                // 上部固定ヘッダーエリア
                HStack(spacing: 12) {
                    if currentStep == 0 {
                        Button(action: handleDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    } else {
                        Button(action: {
                            triggerHaptic(style: .light)
                            isFocused = false
                            withAnimation {
                                currentStep -= 1
                            }
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
                     
                    if currentStep == 1 {
                        Button(action: {
                            triggerHaptic(style: .medium)
                            coffeeRecordViewModel.bitternessrating = 0
                            coffeeRecordViewModel.acidityrating = 0
                            coffeeRecordViewModel.bodyrating = 0
                            coffeeRecordViewModel.sweetnessrating = 0
                            coffeeRecordViewModel.flavorrating = 0
                            coffeeRecordViewModel.selectedAroma = ""
                            
                            withAnimation { currentStep = 2 }
                        }) {
                            Text("次へ")
                                .bold()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(isBasicInfoValid ? Color.blue : Color.gray.opacity(0.4))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .disabled(!isBasicInfoValid)
                        .scaleEffect(isBasicInfoValid ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isBasicInfoValid)
                        .onChange(of: isBasicInfoValid) { _, isValid in
                            if isValid { triggerHaptic(style: .light) }
                        }
                    }
                     
                    if currentStep == 2 {
                        Button(action: {
                            triggerHaptic(style: .medium)
                            isFocused = false
                            withAnimation { currentStep = 3 }
                        }) {
                            Text("次へ")
                                .bold()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(isTasteValid ? Color.blue : Color.gray.opacity(0.4))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .disabled(!isTasteValid)
                        .scaleEffect(isTasteValid ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isTasteValid)
                        .onChange(of: isTasteValid) { _, isValid in
                            if isValid { triggerHaptic(style: .light) }
                        }
                    }

                    if currentStep == 3 {
                        Button(action: {
                            triggerHaptic(style: .heavy)
                            isFocused = false
                            if let currentUser = Auth.auth().currentUser {
                                coffeeRecordViewModel.uploadAndSaveLog(currentUser: currentUser) { success in
                                    if success {
                                        resetStateAndForm()
                                        onCompleted?() ?? dismiss()
                                    }
                                }
                            }
                        }) {
                            Text("投稿する")
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
            .onChange(of: currentStep) { _, _ in isFocused = false }
        }
    }
        
    // MARK: - Steps
        
    @ViewBuilder
    private func cameraStepView() -> some View {
        ZStack(alignment: .bottom) {
            CameraView(
                capturedImage: Binding(
                    get: { coffeeRecordViewModel.logImages.first },
                    set: { if let img = $0 { coffeeRecordViewModel.logImages = [img] } }
                ),
                onImageCaptured: {
                    triggerHaptic(style: .medium)
                    withAnimation { currentStep = 1 }
                },
                triggerCapture: $shouldCapture
            )
            .ignoresSafeArea()
             
            HStack {
                Button(action: { isShowingPhotoPicker = true }) {
                    ZStack {
                        if let lastImage = coffeeRecordViewModel.logImages.first {
                            Image(uiImage: lastImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18))
                                )
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
                        }
                    }
                }
                .photosPicker(isPresented: $isShowingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let newItem,
                           let data = try? await newItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                coffeeRecordViewModel.logImages = [image]
                                triggerHaptic(style: .medium)
                                withAnimation {
                                    currentStep = 1
                                }
                            }
                        }
                    }
                }
                 
                Spacer()
                 
                Button(action: {
                    triggerHaptic(style: .heavy)
                    shouldCapture = true
                }) {
                    ZStack {
                        Circle().stroke(Color.white, lineWidth: 4).frame(width: 76, height: 76)
                        Circle().fill(Color.white).frame(width: 64, height: 64)
                    }
                }
                 
                Spacer()
                 
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
        
    @ViewBuilder
    private func basicInfoStepView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("基本情報").font(.title2).bold().padding(.top, 80)
                
                // 1. 店舗名
                editField(label: "店舗名（必須）", text: $coffeeRecordViewModel.shopName, placeholder: "店舗名を入力")
                
                // 2. 豆の種類
                VStack(alignment: .leading, spacing: 8) {
                    Text("豆の種類").font(.subheadline).foregroundColor(.secondary)
                    Picker("豆の種類", selection: $coffeeRecordViewModel.isBlend) {
                        Text("シングルオリジン").tag(false)
                        Text("ブレンド").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                
                // 3. タイプに応じた動的フォーム
                if coffeeRecordViewModel.isBlend {
                    // --- ブレンドの場合 ---
                    editField(label: "ブレンド名（必須）", text: $coffeeRecordViewModel.blend, placeholder: "ブレンド名を入力")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("含まれている国（含有率の多い国から）")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        blendCountryPickerButton(label: "国 1", country: coffeeRecordViewModel.blendCountry1) {
                            coffeeRecordViewModel.activeCountryTarget = .blend1
                            coffeeRecordViewModel.isShowingCountryPicker = true
                        }
                        blendCountryPickerButton(label: "国 2", country: coffeeRecordViewModel.blendCountry2) {
                            coffeeRecordViewModel.activeCountryTarget = .blend2
                            coffeeRecordViewModel.isShowingCountryPicker = true
                        }
                        blendCountryPickerButton(label: "国 3", country: coffeeRecordViewModel.blendCountry3) {
                            coffeeRecordViewModel.activeCountryTarget = .blend3
                            coffeeRecordViewModel.isShowingCountryPicker = true
                        }
                    }
                } else {
                    // --- シングルオリジンの場合 ---
                    Button(action: {
                        isFocused = false
                        coffeeRecordViewModel.activeCountryTarget = .single
                        coffeeRecordViewModel.isShowingCountryPicker = true
                    }) {
                        HStack {
                            Text("生産国（必須）")
                                .frame(width: 130, alignment: .leading)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(coffeeRecordViewModel.countryName.isEmpty ? "選択してください" : coffeeRecordViewModel.countryName)
                                .foregroundColor(coffeeRecordViewModel.countryName.isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                    }
                    Divider()
                    
                    editField(label: "銘柄 / 品種", text: $coffeeRecordViewModel.blend, placeholder: "銘柄名を入力")
                    editField(label: "農園名", text: $coffeeRecordViewModel.farmName, placeholder: "農園名を入力")
                    editField(label: "グレード", text: $coffeeRecordViewModel.grade, placeholder: "例: G1, AAなど")
                    
                    // 4. 焙煎度（シングルオリジンのみ）
                    Button(action: { isFocused = false; coffeeRecordViewModel.isShowingRoastPicker = true }) {
                        HStack {
                            Text("焙煎度（必須）")
                                .frame(width: 130, alignment: .leading)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(coffeeRecordViewModel.roastLevel.isEmpty ? "選択してください" : coffeeRecordViewModel.roastLevel)
                                .foregroundColor(coffeeRecordViewModel.roastLevel.isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                    }
                    .sheet(isPresented: $coffeeRecordViewModel.isShowingRoastPicker) {
                        RoastSelectionView { coffeeRecordViewModel.roastLevel = $0 }
                    }
                    Divider()
                }
            }
            .padding(24)
        }
        .sheet(isPresented: $coffeeRecordViewModel.isShowingCountryPicker) {
            CountrySelectionView { selectedCountry in
                switch coffeeRecordViewModel.activeCountryTarget {
                case .single:
                    coffeeRecordViewModel.countryName = selectedCountry
                case .blend1:
                    coffeeRecordViewModel.blendCountry1 = selectedCountry
                case .blend2:
                    coffeeRecordViewModel.blendCountry2 = selectedCountry
                case .blend3:
                    coffeeRecordViewModel.blendCountry3 = selectedCountry
                }
            }
        }
    }
        
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(label)
                    .frame(width: 130, alignment: .leading)
                    .foregroundColor(.primary)
                TextField(placeholder, text: text)
                    .focused($isFocused)
            }
            .padding(.vertical, 12)
            Divider()
        }
    }
        
    @ViewBuilder
    private func blendCountryPickerButton(label: String, country: String, action: @escaping () -> Void) -> some View {
        Button(action: { isFocused = false; action() }) {
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
        }
        Divider()
    }
        
    @ViewBuilder
    private func tasteStepView() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("味わいの評価").font(.title2).bold().padding(.top, 80)
                     
                    VStack(alignment: .leading, spacing: 16) {
                        ratingRow(label: "苦味", rating: $coffeeRecordViewModel.bitternessrating)
                        ratingRow(label: "酸味", rating: $coffeeRecordViewModel.acidityrating)
                        ratingRow(label: "コク", rating: $coffeeRecordViewModel.bodyrating)
                        ratingRow(label: "甘味", rating: $coffeeRecordViewModel.sweetnessrating)
                    }
                     
                    Divider()
                     
                    VStack(alignment: .leading, spacing: 12) {
                        ratingRow(label: "フレーバー", rating: $coffeeRecordViewModel.flavorrating)
                        Text("特徴を1つ選択").font(.subheadline).bold()
                        ForEach(coffeeRecordViewModel.flavorOptions, id: \.self) { aroma in
                            let isSelected = coffeeRecordViewModel.selectedAroma == aroma
                            Button(action: {
                                triggerHaptic(style: .light)
                                withAnimation { coffeeRecordViewModel.selectedAroma = isSelected ? "" : aroma }
                            }) {
                                HStack {
                                    Text(aroma).foregroundColor(isSelected ? .white : .primary)
                                    Spacer()
                                    if isSelected { Image(systemName: "checkmark").foregroundColor(.white) }
                                }
                                .padding(14).background(isSelected ? Color.blue : Color(.systemGray6)).cornerRadius(12)
                            }
                        }
                    }
                     
                    Divider()
                     
                    memoField(label: "一言メモ（任意）", text: $coffeeRecordViewModel.memo, placeholder: "例）１口目のインパクトがすごい！\n冷めると酸味が強くなる！\n次はアイスも！etc")
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
    private func previewStepView() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("投稿内容の確認")
                    .font(.title2)
                    .bold()
                    .padding(.top, 50)
                 
                CoffeeLogView(
                    log: previewLog,
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
        
    private func handleDismiss() {
        resetStateAndForm()
        onDismiss?() ?? dismiss()
    }
        
    private func resetStateAndForm() {
        coffeeRecordViewModel.resetForm()
        currentStep = 0
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
        
    @ViewBuilder
    private func ratingRow(label: String, rating: Binding<Int>) -> some View {
        HStack {
            Text(label).frame(width: 80, alignment: .leading)
            Spacer()
            ForEach(1...coffeeRecordViewModel.maxRating, id: \.self) { n in
                Image(n <= rating.wrappedValue ? "coffeeBeanFill" : "coffeeBean")
                    .resizable().frame(width: 26, height: 26)
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
}
