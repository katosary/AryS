//
//  SignUpView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/17.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var authManager: AuthManager
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                viewModel.brandBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // --- ステップインジケーター ---
                    StepIndicatorView(currentStep: viewModel.currentStep)
                        .padding(.vertical, 20)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            Text("アカウントの作成")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            // --- 各ステップのコンテンツ ---
                            switch viewModel.currentStep {
                            case 1:
                                Step1View(
                                    email: $viewModel.email,
                                    password: $viewModel.password,
                                    confirmPassword: $viewModel.confirmPassword // 【追加】確認用パスワード
                                )
                            case 2:
                                Step2View(
                                    name: $viewModel.name,
                                    age: $viewModel.age,
                                    prefecture: $viewModel.prefecture,
                                    addressDetail: $viewModel.addressDetail,
                                    isShowingAgePicker: $viewModel.isShowingAgePicker,
                                    isShowingPrefecturePicker: $viewModel.isShowingPrefecturePicker
                                )
                            case 3:
                                Step3CoffeePreferenceView(
                                    probitter: $viewModel.probitter,
                                    proacidity: $viewModel.proacidity,
                                    probody: $viewModel.probody,
                                    prosweetness: $viewModel.prosweetness,
                                    proflavor: $viewModel.proflavor,
                                    selectedFlavors: $viewModel.selectedFlavors,
                                    flavorOptions: viewModel.flavorOptions,
                                    maxRating: viewModel.maxRating
                                )
                            case 4:
                                Step4ConfirmationView(
                                    email: viewModel.email,
                                    password: viewModel.password,
                                    name: viewModel.name,
                                    age: viewModel.age,
                                    address: viewModel.prefecture + viewModel.addressDetail,
                                    probitter: viewModel.probitter,
                                    proacidity: viewModel.proacidity,
                                    probody: viewModel.probody,
                                    prosweetness: viewModel.prosweetness,
                                    proflavor: viewModel.proflavor,
                                    selectedFlavors: viewModel.selectedFlavors,
                                    maxRating: viewModel.maxRating, // 【追加】レーティング表示用
                                    brandBackgroundColor: viewModel.brandBackgroundColor
                                )
                            default:
                                EmptyView()
                            }
                            
                            if !viewModel.errorMessage.isEmpty {
                                Text(viewModel.errorMessage)
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            // --- 「次へ」または「登録する」ボタン ---
                            Button {
                                if viewModel.currentStep < 4 {
                                    viewModel.nextStep()
                                } else {
                                    viewModel.registerUser(authManager: authManager) {
                                        // 登録成功時の処理があればここに記述
                                    }
                                }
                            } label: {
                                Group {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(viewModel.brandBackgroundColor)
                                    } else {
                                        Text(viewModel.currentStep == 4 ? "登録する" : "次へ")
                                            .font(.headline)
                                            .bold()
                                    }
                                }
                                .foregroundColor(viewModel.brandBackgroundColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(!viewModel.isCurrentStepValid() || viewModel.isLoading ? Color.white.opacity(0.5) : Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                            }
                            .disabled(!viewModel.isCurrentStepValid() || viewModel.isLoading)
                            .padding(.top, 12)
                            
                            // --- 「戻る」ボタン ---
                            Button {
                                if viewModel.currentStep > 1 {
                                    viewModel.previousStep()
                                } else {
                                    dismiss()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("戻る")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ログイン画面に戻る") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("確認メールを送信しました", isPresented: $viewModel.showVerificationAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("ご登録いただいたメールアドレス宛に確認メールを送信しました。メール内のリンクをクリックして認証を完了させてください。")
            }
        }
        .preferredColorScheme(.dark)
        .tint(.white)
    }
}

// MARK: - カスタムテキストフィールドスタイル
struct CustomSignUpTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color.black.opacity(0.2))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

extension View {
    func customSignUpTextFieldStyle() -> some View {
        modifier(CustomSignUpTextFieldStyle())
    }
}

// MARK: - ステップ 1: 基本情報①（メール・パスワード）
struct Step1View: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String // 【追加】確認用パスワード
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("メールアドレス")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                TextField("sample@email.com", text: $email)
                    .customSignUpTextFieldStyle()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("パスワード")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                SecureField("半角英数を含む6文字以上", text: $password)
                    .customSignUpTextFieldStyle()
                Text("半角英数を含む6文字以上")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // 【追加】パスワード（確認）入力欄
            VStack(alignment: .leading, spacing: 8) {
                Text("パスワード（確認）")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                SecureField("もう一度パスワードを入力", text: $confirmPassword)
                    .customSignUpTextFieldStyle()
                
                // 一致しているかどうかの簡易インジケーター（任意で表示）
                if !confirmPassword.isEmpty {
                    if password == confirmPassword {
                        Text("パスワードが一致しています")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Text("パスワードが一致していません")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}

// MARK: - ステップ 2: 基本情報（名前・年齢・住所）
struct Step2View: View {
    @Binding var name: String
    @Binding var age: Int
    @Binding var prefecture: String
    @Binding var addressDetail: String
    @Binding var isShowingAgePicker: Bool
    @Binding var isShowingPrefecturePicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ユーザーネーム
            VStack(alignment: .leading, spacing: 8) {
                Text("ユーザーネーム")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                TextField("お名前を入力", text: $name)
                    .customSignUpTextFieldStyle()
            }
            
            // 年齢
            VStack(alignment: .leading, spacing: 8) {
                Text("年齢")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                
                Button(action: { isShowingAgePicker = true }) {
                    HStack {
                        Text(age == 0 ? "年齢を選択してください" : "\(age) 歳")
                            .foregroundColor(age == 0 ? .white.opacity(0.4) : .white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .sheet(isPresented: $isShowingAgePicker) {
                    AgeSelectionView { age = $0 }
                }
            }
            
            // 住所（都道府県選択 ＋ それ以降の入力）
            VStack(alignment: .leading, spacing: 8) {
                Text("お住まいの地域")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                
                Button(action: { isShowingPrefecturePicker = true }) {
                    HStack {
                        Text(prefecture.isEmpty ? "都道府県を選択してください" : prefecture)
                            .foregroundColor(prefecture.isEmpty ? .white.opacity(0.4) : .white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .sheet(isPresented: $isShowingPrefecturePicker) {
                    PrefectureSelectionView { selectedPrefecture in
                        prefecture = selectedPrefecture
                    }
                    .presentationDetents([.medium])
                }
                
                TextField("市区町村・番地など（任意）", text: $addressDetail)
                    .customSignUpTextFieldStyle()
                    .padding(.top, 4)
            }
        }
    }
}

struct Step3CoffeePreferenceView: View {
    @Binding var probitter: Int
    @Binding var proacidity: Int
    @Binding var probody: Int
    @Binding var prosweetness: Int
    @Binding var proflavor: Int
    @Binding var selectedFlavors: [String]
    
    let flavorOptions: [String]
    let maxRating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("コーヒーの好みについて教えてください")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                
                // 案内文の追加（任意）
                Text("※すべてのレーティング項目を入力してください")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                RatingRow(label: "苦味", rating: $probitter, maxRating: maxRating)
                RatingRow(label: "酸味", rating: $proacidity, maxRating: maxRating)
                RatingRow(label: "コク", rating: $probody, maxRating: maxRating)
                RatingRow(label: "甘味", rating: $prosweetness, maxRating: maxRating)
                RatingRow(label: "フレーバー", rating: $proflavor, maxRating: maxRating)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("お気に入りのフレーバー（最大3つまで）")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(flavorOptions, id: \.self) { aroma in
                        let isSelected = selectedFlavors.contains(aroma)
                        let isMaxReached = selectedFlavors.count >= 3
                        
                        Button(action: {
                            withAnimation {
                                var current = selectedFlavors
                                if isSelected {
                                    current.removeAll { $0 == aroma }
                                } else {
                                    if current.count < 3 {
                                        current.append(aroma)
                                    }
                                }
                                selectedFlavors = current
                            }
                        }) {
                            HStack {
                                Text(aroma)
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(isSelected ? Color.white.opacity(0.3) : Color.black.opacity(0.2))
                            .foregroundColor(isSelected ? .white : (isMaxReached && !isSelected ? .white.opacity(0.4) : .white.opacity(0.8)))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 共通レイアウト用レーティング行ビュー
struct RatingRow: View {
    let label: String
    @Binding var rating: Int
    let maxRating: Int
    var isInteractive: Bool = true
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7)) // 他の項目と色味を合わせる場合
                .frame(width: 140, alignment: .leading) // 他のConfirmationRowのタイトル幅（140）と統一
            
            Spacer() // ← ここにSpacerを入れることで、右側に押しやる
            
            HStack(spacing: 6) {
                ForEach(1...maxRating, id: \.self) { number in
                    let isSelected = number <= rating
                    
                    Image(isSelected ? "coffeeBeanFill" : "coffeeBean")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(isSelected ? .yellow : .white.opacity(0.3))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isInteractive {
                                rating = number
                            }
                        }
                }
            }
        }
    }
}

// MARK: - ステップ 4: 入力確認
struct Step4ConfirmationView: View {
    let email: String
    let password: String
    let name: String
    let age: Int
    let address: String
    let probitter: Int
    let proacidity: Int
    let probody: Int
    let prosweetness: Int
    let proflavor: Int
    let selectedFlavors: [String]
    let maxRating: Int
    let brandBackgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("入力内容のご確認")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                ConfirmationRow(title: "メールアドレス", value: email)
                ConfirmationRow(title: "パスワード", value: "••••••••")
                ConfirmationRow(title: "ユーザーネーム", value: name)
                ConfirmationRow(title: "年齢", value: "\(age) 歳")
                ConfirmationRow(title: "住所", value: address)
                
                Divider().background(Color.white.opacity(0.2))
                
                // 【変更】コーヒーの好みをCoffeeBeanのRatingViewで表示
                RatingRow(label: "苦味", rating: .constant(probitter), maxRating: maxRating, isInteractive: false)
                RatingRow(label: "酸味", rating: .constant(proacidity), maxRating: maxRating, isInteractive: false)
                RatingRow(label: "コク", rating: .constant(probody), maxRating: maxRating, isInteractive: false)
                RatingRow(label: "甘味", rating: .constant(prosweetness), maxRating: maxRating, isInteractive: false)
                RatingRow(label: "フレーバー", rating: .constant(proflavor), maxRating: maxRating, isInteractive: false)
                
                ConfirmationRow(title: "お気に入りフレーバー", value: selectedFlavors.isEmpty ? "未選択" : selectedFlavors.joined(separator: ", "))
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct ConfirmationRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundColor(.white.opacity(0.7))
                .font(.subheadline)
                .frame(width: 140, alignment: .leading)
            Spacer()
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - ステップインジケーター（上部のバー・全4ステップ）
struct StepIndicatorView: View {
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 0) {
            StepCircleView(stepNumber: 1, title: "基本①", currentStep: currentStep)
            StepLineView(isActive: currentStep > 1)
            
            StepCircleView(stepNumber: 2, title: "基本②", currentStep: currentStep)
            StepLineView(isActive: currentStep > 2)
            
            StepCircleView(stepNumber: 3, title: "好み", currentStep: currentStep)
            StepLineView(isActive: currentStep > 3)
            
            StepCircleView(stepNumber: 4, title: "確認", currentStep: currentStep)
        }
        .padding(.horizontal, 16)
    }
}

struct StepCircleView: View {
    let stepNumber: Int
    let title: String
    let currentStep: Int
    
    var isCompleted: Bool { currentStep > stepNumber }
    var isCurrent: Bool { currentStep == stepNumber }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isCompleted || isCurrent ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 28, height: 28)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 89/255, green: 61/255, blue: 43/255))
                } else {
                    Text("\(stepNumber)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isCurrent ? Color(red: 89/255, green: 61/255, blue: 43/255) : .white)
                }
            }
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(isCurrent ? .white : .white.opacity(0.6))
        }
    }
}

struct StepLineView: View {
    let isActive: Bool
    
    var body: some View {
        Rectangle()
            .fill(isActive ? Color.white : Color.white.opacity(0.3))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
            .offset(y: -8)
    }
}

// MARK: - プレビュー
#Preview {
    SignUpView(authManager: AuthManager())
}
