//
//  CoffeeRecordView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import SwiftUI
import FirebaseAuth
import PhotosUI
import UIKit // 💡 振動（Haptic Feedback）用

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
    
    // 💡 基本情報の必須チェック（店舗名・ブレンド名・生産国・焙煎度が入力/選択されているか）
    private var isBasicInfoValid: Bool {
        !coffeeRecordViewModel.shopName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !coffeeRecordViewModel.blend.trimmingCharacters(in: .whitespaces).isEmpty &&
        !coffeeRecordViewModel.countryName.isEmpty &&
        !coffeeRecordViewModel.roastLevel.isEmpty
    }
    
    // 💡 味わいの評価の必須チェック（苦味・酸味・コク・甘味・フレーバー評価が0より大きく、特徴タグも1つ選択されているか）
    private var isTasteValid: Bool {
        coffeeRecordViewModel.bitternessrating > 0 &&
        coffeeRecordViewModel.acidityrating > 0 &&
        coffeeRecordViewModel.bodyrating > 0 &&
        coffeeRecordViewModel.sweetnessrating > 0 &&
        coffeeRecordViewModel.aromarating > 0 &&
        !coffeeRecordViewModel.selectedAroma.isEmpty
    }
    
    private var previewLog: Log {
        Log(
            id: nil,
            userId: Auth.auth().currentUser?.uid ?? "",
            shopName: coffeeRecordViewModel.shopName.isEmpty ? "店舗名未入力" : coffeeRecordViewModel.shopName,
            blend: coffeeRecordViewModel.blend,
            countryName: coffeeRecordViewModel.countryName.isEmpty ? "生産国未入力" : coffeeRecordViewModel.countryName,
            farmName: coffeeRecordViewModel.farmName,
            grade: coffeeRecordViewModel.grade,
            roastLevel: coffeeRecordViewModel.roastLevel,
            flavorrating: coffeeRecordViewModel.aromarating,
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
                // 💡 メインコンテンツ（横スワイプをなくし、switch文でステップを制御）
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
                 
                // 上部固定ヘッダーエリア（×ボタン / 戻るボタン と 右上のアクションボタン）
                HStack(spacing: 12) {
                    // ×ボタン (Step 0のとき) または 戻るボタン (Step 1〜3のとき)
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
                     
                    // 💡 Step 1: 基本情報の「次へ」ボタン
                    if currentStep == 1 {
                        Button(action: {
                            triggerHaptic(style: .medium)
                            
                            // 💡 味わい評価画面に遷移する直前に、味わいの評価項目を一旦リセットして必ず「未選択（灰色）」からスタートさせる
                            coffeeRecordViewModel.bitternessrating = 0
                            coffeeRecordViewModel.acidityrating = 0
                            coffeeRecordViewModel.bodyrating = 0
                            coffeeRecordViewModel.sweetnessrating = 0
                            coffeeRecordViewModel.aromarating = 0
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
                            if isValid {
                                triggerHaptic(style: .light)
                            }
                        }
                    }
                    
                    // 💡 Step 2: 味わいの評価の「次へ」ボタン
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
                            if isValid {
                                triggerHaptic(style: .light)
                            }
                        }
                    }

                    // 💡 Step 3: 「投稿する」ボタン
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
            VStack(alignment: .leading, spacing: 24) {
                Text("基本情報").font(.title2).bold().padding(.top, 80)
                editField(label: "店舗名（必須）", text: $coffeeRecordViewModel.shopName, placeholder: "店舗名を入力")
                editField(label: "ブレンド名（必須）", text: $coffeeRecordViewModel.blend, placeholder: "ブレンド名 / 銘柄名を入力")
                editField(label: "農園名", text: $coffeeRecordViewModel.farmName, placeholder: "農園名を入力")
                editField(label: "グレード", text: $coffeeRecordViewModel.grade, placeholder: "グレードを入力 (例: G1, AAなど)")
                 
                Button(action: { isFocused = false; coffeeRecordViewModel.isShowingCountryPicker = true }) {
                    HStack {
                        Text("生産国（必須）").foregroundColor(.primary)
                        Spacer()
                        Text(coffeeRecordViewModel.countryName.isEmpty ? "選択してください" : coffeeRecordViewModel.countryName)
                            .foregroundColor(coffeeRecordViewModel.countryName.isEmpty ? .secondary : .primary)
                    }
                }
                .sheet(isPresented: $coffeeRecordViewModel.isShowingCountryPicker) {
                    CountrySelectionView { coffeeRecordViewModel.countryName = $0 }
                }
                Divider()
                 
                Button(action: { isFocused = false; coffeeRecordViewModel.isShowingRoastPicker = true }) {
                    HStack {
                        Text("焙煎度（必須）").foregroundColor(.primary)
                        Spacer()
                        Text(coffeeRecordViewModel.roastLevel.isEmpty ? "選択してください" : coffeeRecordViewModel.roastLevel)
                            .foregroundColor(coffeeRecordViewModel.roastLevel.isEmpty ? .secondary : .primary)
                    }
                }
                .sheet(isPresented: $coffeeRecordViewModel.isShowingRoastPicker) {
                    RoastSelectionView { coffeeRecordViewModel.roastLevel = $0 }
                }
            }
            .padding(24)
        }
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
                        ratingRow(label: "フレーバー", rating: $coffeeRecordViewModel.aromarating)
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
      
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack {
            HStack { Text(label).frame(width: 120); TextField(placeholder, text: text).focused($isFocused) }
            Divider()
        }
    }
}
