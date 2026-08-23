//
//  CoffeeRecordView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import SwiftUI
import FirebaseAuth

struct CoffeeRecordView: View {
    @State var coffeeRecordViewModel = CoffeeRecordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var shouldCapture = false
    
    @FocusState private var isFocused: Bool
    
    var onDismiss: (() -> Void)?
    var onCompleted: (() -> Void)?
    
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
            sweetnessrating: coffeeRecordViewModel.sweetnessrating, // 追加: 画面から取得
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
                // メインコンテンツ
                VStack(spacing: 0) {
                    TabView(selection: $currentStep) {
                        cameraStepView().tag(0)
                        basicInfoStepView().tag(1)
                        tasteStepView().tag(2)
                        previewStepView().tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .background(Color(.systemGroupedBackground))
                 
                // 上部固定ヘッダーエリア（×ボタンと投稿ボタン）
                HStack {
                    // ×ボタン
                    Button(action: handleDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                     
                    Spacer()
                     
                    // 「投稿する」ボタン（Step 3の時だけ表示）
                    if currentStep == 3 {
                        Button(action: {
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
            .onChange(of: currentStep) { isFocused = false }
        }
    }
      
    // MARK: - Steps
      
    @ViewBuilder
    private func cameraStepView() -> some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
             
            VStack {
                Spacer()
                 
                ZStack(alignment: .bottom) {
                    CameraView(
                        capturedImage: Binding(
                            get: { coffeeRecordViewModel.logImages.first },
                            set: { if let img = $0 { coffeeRecordViewModel.logImages = [img] } }
                        ),
                        onImageCaptured: { withAnimation { currentStep = 1 } },
                        triggerCapture: $shouldCapture
                    )
                    .aspectRatio(9/16, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                     
                    // シャッターボタン
                    Button(action: { shouldCapture = true }) {
                        ZStack {
                            Circle().stroke(Color.white, lineWidth: 4).frame(width: 76, height: 76)
                            Circle().fill(Color.white).frame(width: 64, height: 64)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 16)
                 
                Spacer()
            }
        }
    }
      
    @ViewBuilder
    private func basicInfoStepView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("基本情報").font(.title2).bold().padding(.top, 80)
                editField(label: "店舗名", text: $coffeeRecordViewModel.shopName, placeholder: "店舗名を入力")
                editField(label: "ブレンド名", text: $coffeeRecordViewModel.blend, placeholder: "ブレンド名 / 銘柄名を入力")
                editField(label: "農園名", text: $coffeeRecordViewModel.farmName, placeholder: "農園名を入力")
                // 💡 修正: FarmNameのテキストボックスの下にgradeのテキストボックスを追加
                editField(label: "グレード", text: $coffeeRecordViewModel.grade, placeholder: "グレードを入力 (例: G1, AAなど)")
                 
                Button(action: { isFocused = false; coffeeRecordViewModel.isShowingCountryPicker = true }) {
                    HStack {
                        Text("生産国").foregroundColor(.primary)
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
                        Text("焙煎度").foregroundColor(.primary)
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
                     
                    // 1. 評価項目（苦味、酸味、コク、甘味）
                    VStack(alignment: .leading, spacing: 16) {
                        ratingRow(label: "苦味", rating: $coffeeRecordViewModel.bitternessrating)
                        ratingRow(label: "酸味", rating: $coffeeRecordViewModel.acidityrating)
                        ratingRow(label: "コク", rating: $coffeeRecordViewModel.bodyrating)
                        // 💡 修正: コクの下に甘味のRatingを追加
                        ratingRow(label: "甘味", rating: $coffeeRecordViewModel.sweetnessrating)
                    }
                     
                    Divider()
                     
                    // 2. フレーバーの特徴
                    VStack(alignment: .leading, spacing: 12) {
                        ratingRow(label: "フレーバー", rating: $coffeeRecordViewModel.aromarating)
                        Text("特徴を1つ選択").font(.subheadline).bold()
                        ForEach(coffeeRecordViewModel.flavorOptions, id: \.self) { aroma in
                            let isSelected = coffeeRecordViewModel.selectedAroma == aroma
                            Button(action: { withAnimation { coffeeRecordViewModel.selectedAroma = isSelected ? "" : aroma } }) {
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
                     
                    // 3. 一言メモ
                    memoField(label: "一言メモ（任意）", text: $coffeeRecordViewModel.memo, placeholder: "例）１口目のインパクトがすごい！\n冷めると酸味が強くなる！\n次はアイスも！etc")
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
    private func previewStepView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("投稿内容の確認").font(.title2).bold().padding(.top, 80)
                CoffeeLogView(log: previewLog, author: nil, authorName: "あなた", isEditable: false, onTapMenu: {}, onTapLike: {}, onTapBookmark: {}, onTapProfile: {})
                    .cornerRadius(16).shadow(radius: 4)
            }
            .padding(24)
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
      
    @ViewBuilder
    private func ratingRow(label: String, rating: Binding<Int>) -> some View {
        HStack {
            Text(label).frame(width: 80, alignment: .leading)
            Spacer()
            ForEach(1...coffeeRecordViewModel.maxRating, id: \.self) { n in
                Image(n <= rating.wrappedValue ? "coffeeBeanFill" : "coffeeBean")
                    .resizable().frame(width: 26, height: 26)
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
            HStack { Text(label).frame(width: 80); TextField(placeholder, text: text).focused($isFocused) }
            Divider()
        }
    }
}
