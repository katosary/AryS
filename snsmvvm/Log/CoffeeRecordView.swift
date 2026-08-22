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
    @State private var maxUnlockedStep = 0
    @State private var shouldCapture = false
    
    // キーボードを閉じるためのフォーカス状態
    @FocusState private var isFocused: Bool
    
    var onDismiss: (() -> Void)?
    var onCompleted: (() -> Void)?
    
    private var previewLog: Log {
        Log(
            id: nil,
            userId: Auth.auth().currentUser?.uid ?? "",
            shopName: coffeeRecordViewModel.shopName.isEmpty ? "店舗名未入力" : coffeeRecordViewModel.shopName,
            countryName: coffeeRecordViewModel.countryName.isEmpty ? "生産国未入力" : coffeeRecordViewModel.countryName,
            farmName: coffeeRecordViewModel.farmName,
            roastLevel: coffeeRecordViewModel.roastLevel,
            aromarating: coffeeRecordViewModel.aromarating,
            aromaComment: coffeeRecordViewModel.memo, // 💡 memo を反映
            bitternessrating: coffeeRecordViewModel.bitternessrating,
            acidityrating: coffeeRecordViewModel.acidityrating,
            bodyrating: coffeeRecordViewModel.bodyrating,
            createdAt: Date(),
            tagX: 0.0,
            tagY: 0.0,
            imageUrl: nil,
            previewImage: coffeeRecordViewModel.logImages.first
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    TabView(selection: $currentStep) {
                        cameraStepView()
                            .tag(0)
                        
                        basicInfoStepView()
                            .tag(1)
                            .disabled(maxUnlockedStep < 1)
                        
                        // 💡 統合: 香りと味わいをまとめた評価ステップ
                        tasteStepView()
                            .tag(2)
                            .disabled(maxUnlockedStep < 2)
                        
                        // 💡 変更: プレビューのタグを 3 に変更
                        previewStepView()
                            .tag(3)
                            .disabled(maxUnlockedStep < 3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .background(Color(.systemGroupedBackground))
                
                Button(action: handleDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(currentStep == 0 ? .white : .primary)
                        .padding(10)
                        .background(currentStep == 0 ? Color.black.opacity(0.5) : Color(.systemGray5))
                        .clipShape(Circle())
                }
                .padding(.leading, 16)
                .padding(.top, 16)
            }
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: currentStep) {
                isFocused = false
            }
        }
    }
    
    // MARK: - Step Views (@ViewBuilder)
    
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
                            set: { newImage in
                                if let img = newImage {
                                    coffeeRecordViewModel.logImages = [img]
                                }
                            }
                        ),
                        onImageCaptured: {
                            checkAndProgress(to: 1, condition: true)
                        },
                        triggerCapture: $shouldCapture
                    )
                    .aspectRatio(9/16, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            shouldCapture = true
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 76, height: 76)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 64, height: 64)
                            }
                        }
                        Spacer()
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
            VStack {
                Spacer(minLength: 0)
                
                VStack(alignment: .leading, spacing: 16) {
                    stepHeader(title: "Step 1: 基本情報", isComplete: isStep1Complete())
                    
                    editField(label: "店舗名", text: $coffeeRecordViewModel.shopName, placeholder: "店舗名を入力")
                        .onChange(of: coffeeRecordViewModel.shopName) {
                            checkAndProgress(to: 2, condition: isStep1Complete())
                        }
                    
                    editField(label: "農園名", text: $coffeeRecordViewModel.farmName, placeholder: "農園名を入力")
                    
                    Button(action: {
                        isFocused = false
                        coffeeRecordViewModel.isShowingCountryPicker = true
                    }) {
                        HStack {
                            Text("生産国").foregroundColor(.primary)
                            Spacer()
                            Text(coffeeRecordViewModel.countryName.isEmpty ? "選択してください" : coffeeRecordViewModel.countryName)
                                .foregroundColor(coffeeRecordViewModel.countryName.isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $coffeeRecordViewModel.isShowingCountryPicker) {
                        CountrySelectionView { selectedCountry in
                            coffeeRecordViewModel.countryName = selectedCountry
                            checkAndProgress(to: 2, condition: isStep1Complete())
                        }
                    }
                    Divider()
                    
                    Button(action: {
                        isFocused = false
                        coffeeRecordViewModel.isShowingRoastPicker = true
                    }) {
                        HStack {
                            Text("焙煎度").foregroundColor(.primary)
                            Spacer()
                            Text(coffeeRecordViewModel.roastLevel.isEmpty ? "選択してください" : coffeeRecordViewModel.roastLevel)
                                .foregroundColor(coffeeRecordViewModel.roastLevel.isEmpty ? .secondary : .primary)
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $coffeeRecordViewModel.isShowingRoastPicker) {
                        RoastSelectionView { selectedRoast in
                            coffeeRecordViewModel.roastLevel = selectedRoast
                            checkAndProgress(to: 2, condition: isStep1Complete())
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
    private func tasteStepView() -> some View {
        ScrollView {
            VStack {
                Spacer(minLength: 0)
                
                VStack(alignment: .leading, spacing: 16) {
                    stepHeader(title: "Step 2: 味わいの評価", isComplete: isStep2Complete())
                    
                    // --- 香りの評価 ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("フレーバーの評価").font(.subheadline).bold()
                        ratingRow(label: "強さ", rating: $coffeeRecordViewModel.aromarating, stepIndex: 2) {}
                        
                        Text("特徴を選択").font(.caption).foregroundColor(.secondary)
                        
                        // フレーバーの選択肢（縦並べ）
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(coffeeRecordViewModel.flavorOptions, id: \.self) { aroma in
                                let isSelected = coffeeRecordViewModel.selectedAromas.contains(aroma)
                                Button(action: {
                                    withAnimation {
                                        if isSelected {
                                            coffeeRecordViewModel.selectedAromas.removeAll { $0 == aroma }
                                        } else {
                                            coffeeRecordViewModel.selectedAromas.append(aroma)
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
                        
                        ratingRow(label: "苦味", rating: $coffeeRecordViewModel.bitternessrating, stepIndex: 3) {}
                        ratingRow(label: "酸味", rating: $coffeeRecordViewModel.acidityrating, stepIndex: 3) {}
                        ratingRow(label: "コク", rating: $coffeeRecordViewModel.bodyrating, stepIndex: 3) {}
                    }
                    
                    Divider()
                    
                    // --- 一言メモ（コクの下に実装・TextEditorベース） ---
                    VStack(alignment: .leading, spacing: 8) {
                        memoField(
                            label: "一言メモ",
                            text: $coffeeRecordViewModel.memo,
                            placeholder: "例）１口目のインパクトがすごい！\n冷めると酸味が強くなる！\n次はアイスも！etc"
                        )
                    }
                    
                    // --- 確認画面へ進むボタン ---
                    Button(action: {
                        isFocused = false
                        checkAndProgress(to: 3, condition: isStep2Complete())
                    }) {
                        Text("確認画面へ進む")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isStep2Complete() ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!isStep2Complete())
                    .padding(.top, 8)
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
    private func previewStepView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    stepHeader(title: "Step 3: 投稿の確認", isComplete: false)
                    
                    Button {
                        isFocused = false
                        if let currentUser = Auth.auth().currentUser {
                            coffeeRecordViewModel.uploadAndSaveLog(currentUser: currentUser) { success in
                                if success {
                                    resetStateAndForm()
                                    if let onCompleted = onCompleted {
                                        onCompleted()
                                    } else {
                                        dismiss()
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("投稿する")
                            .bold()
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                
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
            .padding(24)
        }
        .onTapGesture {
            isFocused = false
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleDismiss() {
        isFocused = false
        resetStateAndForm()
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            dismiss()
        }
    }
    
    private func resetStateAndForm() {
        coffeeRecordViewModel.resetForm()
        currentStep = 0
        maxUnlockedStep = 0
    }
    
    private func isStep1Complete() -> Bool {
        return !coffeeRecordViewModel.shopName.isEmpty &&
        !coffeeRecordViewModel.countryName.isEmpty &&
        !coffeeRecordViewModel.roastLevel.isEmpty
    }
    
    // 💡 統合に伴う完了条件（香りの強さ、または苦味・酸味・コクのいずれかが入力されているなど、お好みに合わせて調整してください）
    private func isStep2Complete() -> Bool {
        return coffeeRecordViewModel.aromarating > 0 ||
        coffeeRecordViewModel.bitternessrating > 0 ||
        coffeeRecordViewModel.acidityrating > 0 ||
        coffeeRecordViewModel.bodyrating > 0
    }
    
    private func checkAndProgress(to nextStep: Int, condition: Bool) {
        if condition {
            if maxUnlockedStep < nextStep {
                maxUnlockedStep = nextStep
            }
            withAnimation {
                currentStep = nextStep
            }
        }
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
    private func ratingRow(label: String, rating: Binding<Int>, stepIndex: Int, onChanged: @escaping () -> Void) -> some View {
        HStack {
            Text(label).frame(width: 50, alignment: .leading).font(.subheadline)
            Spacer()
            ForEach(1...coffeeRecordViewModel.maxRating, id: \.self) { number in
                let isSelected = number <= rating.wrappedValue
                
                Image(isSelected ? "coffeeBeanFill" : "coffeeBean")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(isSelected ? coffeeRecordViewModel.onColor : coffeeRecordViewModel.offColor)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isFocused = false
                        rating.wrappedValue = number
                        onChanged()
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
                
                ZStack(alignment: .topLeading) {
                    // 1. まず背景と角丸をZStackのベースに適用する
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 100)
                    
                    // 2. TextEditor をその上に配置（背景は完全に隠す）
                    TextEditor(text: text)
                        .frame(height: 100)
                        .padding(4)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear) // 透明にしておく
                    
                    // 3. プレースホルダーを一番上に重ねる（文字が入力されたら非表示にする）
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .font(.body)
                            .foregroundColor(Color(.placeholderText))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12) // TextEditor内部の余白に合わせる
                            .allowsHitTesting(false) // タップが後ろのTextEditorに抜けるようにする
                    }
                }
            }
        }
    
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).frame(width: 80, alignment: .leading)
                TextField(placeholder, text: text)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isFocused = false
                    }
            }
            .padding(.vertical, 4)
            Divider()
        }
    }
}
