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
    
    // 💡 親ビュー（HomeViewなど）へ通知するためのクロージャ
    var onDismiss: (() -> Void)?
    var onCompleted: (() -> Void)?
    
    // カメラ撮影をトリガーするためのスイッチ
    @State private var shouldCapture = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    
                    // --- Step 0: カメラファインダー画面 ---
                    ZStack(alignment: .topLeading) {
                        // 背景を黒くして上下の余白を馴染ませる
                        Color.black.ignoresSafeArea()

                        // 画面中央に 9:16 の固定枠（カードと同じ比率）を配置するコンテナ
                        VStack {
                            Spacer()
                            
                            ZStack(alignment: .bottom) {
                                // 💡 1. プレビューを正確な 9:16 の枠に収める
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
                                .aspectRatio(9/16, contentMode: .fit) // 9:16の比率を維持
                                .clipShape(RoundedRectangle(cornerRadius: 24)) // 角丸にする場合
                                
                                // シャッターボタン
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
                            .padding(.horizontal, 16) // 左右に適度な余白を持たせてカード状にする
                            
                            Spacer()
                        }

                        // --- 左上の閉じる「✖︎」ボタン ---
                        Button {
                            if let onDismiss = onDismiss {
                                onDismiss() // 💡 クロージャが設定されていればそれを呼ぶ（Homeへ戻る等）
                            } else {
                                dismiss()   // 設定されていなければ通常のdismiss
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 16)
                        .padding(.top, 16)
                    }
                    .tag(0)
                    
                    // --- Step 1: 基本情報 ---
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
                    .tag(1)
                    .disabled(maxUnlockedStep < 1)

                    // --- Step 2: 香り ---
                    ScrollView {
                        VStack {
                            Spacer(minLength: 0)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                stepHeader(title: "Step 2: 香りの評価", isComplete: isStep2Complete())
                                
                                HStack {
                                    Text("強さ").frame(width: 50, alignment: .leading)
                                    Spacer()
                                    ForEach(1...coffeeRecordViewModel.maxRating, id: \.self) { number in
                                        coffeeRecordViewModel.image(for: number, rating: coffeeRecordViewModel.aromarating)
                                            .font(.system(size: 26))
                                            .foregroundColor(number > coffeeRecordViewModel.aromarating ? coffeeRecordViewModel.offColor : coffeeRecordViewModel.onColor)
                                            .onTapGesture {
                                                coffeeRecordViewModel.aromarating = number
                                                checkAndProgress(to: 3, condition: isStep2Complete())
                                            }
                                    }
                                }
                                
                                TextField("どんな香りでしたか？", text: $coffeeRecordViewModel.aromaComment)
                                    .textFieldStyle(.roundedBorder)
                            }
                            .padding(24)
                            
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 500)
                    }
                    .tag(2)
                    .disabled(maxUnlockedStep < 2)

                    // --- Step 3: 味わい評価 ---
                    ScrollView {
                        VStack {
                            Spacer(minLength: 0)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                stepHeader(title: "Step 3: 味わいの評価", isComplete: isStep3Complete())
                                
                                VStack(spacing: 16) {
                                    ratingRow(label: "苦味", rating: $coffeeRecordViewModel.bitternessrating, stepIndex: 4)
                                    ratingRow(label: "酸味", rating: $coffeeRecordViewModel.acidityrating, stepIndex: 4)
                                    ratingRow(label: "コク", rating: $coffeeRecordViewModel.bodyrating, stepIndex: 4)
                                }
                            }
                            .padding(24)
                            
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 500)
                    }
                    .tag(3)
                    .disabled(maxUnlockedStep < 3)
                    
                    // --- Step 4: 投稿プレビュー & 投稿 ---
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                stepHeader(title: "Step 4: 投稿の確認", isComplete: false)

                                Button {
                                    if let currentUser = Auth.auth().currentUser {
                                        coffeeRecordViewModel.uploadAndSaveLog(currentUser: currentUser) { success in
                                            if success {
                                                // 💡 投稿成功時：onCompleted があれば実行、なければ dismiss
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
                            
                            let previewLog = Log(
                                id: "preview_id",
                                userId: Auth.auth().currentUser?.uid ?? "",
                                shopName: coffeeRecordViewModel.shopName.isEmpty ? "店舗名未入力" : coffeeRecordViewModel.shopName,
                                countryName: coffeeRecordViewModel.countryName.isEmpty ? "生産国未入力" : coffeeRecordViewModel.countryName,
                                farmName: coffeeRecordViewModel.farmName,
                                roastLevel: coffeeRecordViewModel.roastLevel,
                                aromarating: coffeeRecordViewModel.aromarating,
                                aromaComment: coffeeRecordViewModel.aromaComment,
                                bitternessrating: coffeeRecordViewModel.bitternessrating,
                                acidityrating: coffeeRecordViewModel.acidityrating,
                                bodyrating: coffeeRecordViewModel.bodyrating,
                                createdAt: Date(),
                                tagX: 0.0,
                                tagY: 0.0,
                                imageUrl: nil,
                                previewImage: coffeeRecordViewModel.logImages.first
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
                    .disabled(maxUnlockedStep < 4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }

    
    // MARK: - 各ステップの完了判定ロジック
    private func isStep1Complete() -> Bool {
        return !coffeeRecordViewModel.shopName.isEmpty &&
               !coffeeRecordViewModel.countryName.isEmpty &&
               !coffeeRecordViewModel.roastLevel.isEmpty
    }
    
    private func isStep2Complete() -> Bool {
        return coffeeRecordViewModel.aromarating > 0
    }
    
    private func isStep3Complete() -> Bool {
        return coffeeRecordViewModel.bitternessrating > 0 ||
               coffeeRecordViewModel.acidityrating > 0 ||
               coffeeRecordViewModel.bodyrating > 0
    }
    
    private func checkAndProgress(to nextStep: Int, condition: Bool) {
        if condition {
            if maxUnlockedStep < nextStep {
                maxUnlockedStep = nextStep
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    currentStep = nextStep
                }
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
    private func ratingRow(label: String, rating: Binding<Int>, stepIndex: Int) -> some View {
        HStack {
            Text(label).frame(width: 50, alignment: .leading)
            Spacer()
            ForEach(1...coffeeRecordViewModel.maxRating, id: \.self) { number in
                coffeeRecordViewModel.image(for: number, rating: rating.wrappedValue)
                    .font(.system(size: 26))
                    .foregroundColor(number > rating.wrappedValue ? coffeeRecordViewModel.offColor : coffeeRecordViewModel.onColor)
                    .onTapGesture {
                        rating.wrappedValue = number
                        checkAndProgress(to: stepIndex, condition: isStep3Complete())
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
