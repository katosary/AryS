//
//  StoreSignUpView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/02.
//

import SwiftUI

struct StoreSignUpView: View {
    @State var viewModel = StoreSignUpViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                viewModel.brandBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    StoreStepIndicatorView(currentStep: viewModel.currentStep)
                        .padding(.vertical, 20)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            Text("店舗アカウントの作成")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            switch viewModel.currentStep {
                            case 1:
                                StoreStep1View(
                                    storeName: $viewModel.storeName,
                                    postalCode: $viewModel.postalCode,
                                    prefecture: $viewModel.prefecture,
                                    city: $viewModel.city,
                                    streetNumber: $viewModel.streetNumber,
                                    buildingName: $viewModel.buildingName,
                                    phoneNumber: $viewModel.phoneNumber,
                                    email: $viewModel.email,
                                    password: $viewModel.password,
                                    confirmPassword: $viewModel.confirmPassword,
                                    isFetchingAddress: viewModel.isFetchingAddress,
                                    onPostalCodeChanged: {
                                        viewModel.fetchAddressByPostalCode()
                                    }
                                )
                            case 2:
                                StoreStep2View(
                                    roasterName: $viewModel.roasterName,
                                    roastingExperience: $viewModel.roastingExperience,
                                    roasterBio: $viewModel.roasterBio,
                                    roastingMachine: $viewModel.roastingMachine,
                                    selectedBusinessModel: $viewModel.selectedBusinessModel,
                                    selectedRevenue: $viewModel.selectedRevenue,
                                    desiredPlatformFeatures: $viewModel.desiredPlatformFeatures,
                                    futureExpectations: $viewModel.futureExpectations
                                )
                            case 3:
                                StoreStep3View(
                                    storeName: viewModel.storeName,
                                    fullAddress: "〒\(viewModel.postalCode) \(viewModel.prefecture)\(viewModel.city)\(viewModel.streetNumber) \(viewModel.buildingName)",
                                    phoneNumber: viewModel.phoneNumber,
                                    email: viewModel.email,
                                    roasterName: viewModel.roasterName,
                                    roastingExperience: viewModel.roastingExperience,
                                    roasterBio: viewModel.roasterBio,
                                    roastingMachine: viewModel.roastingMachine,
                                    businessModel: viewModel.selectedBusinessModel,
                                    estimatedRevenue: viewModel.selectedRevenue,
                                    desiredFeatures: viewModel.desiredPlatformFeatures,
                                    expectations: viewModel.futureExpectations,
                                    isTermsAccepted: $viewModel.isTermsAccepted,
                                    isPrivacyAccepted: $viewModel.isPrivacyAccepted
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
                            
                            Button {
                                if viewModel.currentStep < viewModel.totalSteps {
                                    viewModel.nextStep()
                                } else {
                                    viewModel.registerStore {
                                    }
                                }
                            } label: {
                                Group {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(viewModel.brandBackgroundColor)
                                    } else {
                                        Text(viewModel.currentStep == viewModel.totalSteps ? "登録する" : "次へ")
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
                    .id(viewModel.currentStep)
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
            // 登録成功時に EmailVerificationNoticeView へ遷移
            .navigationDestination(isPresented: $viewModel.isVerificationNoticePresented) {
                StoreEmailVerificationNoticeView()
                    .navigationBarBackButtonHidden(true)
            }
        }
        .preferredColorScheme(.dark)
        .tint(.white)
    }
}

// MARK: - ステップ 1: 店舗・基本情報
struct StoreStep1View: View {
    @Binding var storeName: String
    @Binding var postalCode: String
    @Binding var prefecture: String
    @Binding var city: String
    @Binding var streetNumber: String
    @Binding var buildingName: String
    @Binding var phoneNumber: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    
    let isFetchingAddress: Bool
    let onPostalCodeChanged: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("店舗名（屋号）")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                TextField("例: カフェ・サンプル", text: $storeName)
                    .textFieldStyle(StoreTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("郵便番号")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    TextField("例: 1500002", text: $postalCode)
                        .textFieldStyle(StoreTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onChange(of: postalCode) { _, newValue in
                            if newValue.count >= 7 {
                                onPostalCodeChanged()
                            }
                        }
                    
                    if isFetchingAddress {
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("都道府県")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                TextField("例: 東京都", text: $prefecture)
                    .textFieldStyle(StoreTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("市区町村")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                TextField("例: 渋谷区渋谷", text: $city)
                    .textFieldStyle(StoreTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("番地")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                TextField("例: 1-2-3", text: $streetNumber)
                    .textFieldStyle(StoreTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("建物名・部屋番号")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                TextField("例: カフェビル1F", text: $buildingName)
                    .textFieldStyle(StoreTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("店舗電話番号")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                TextField("例: 09012345678", text: $phoneNumber)
                    .textFieldStyle(StoreTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("店舗メールアドレス")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                TextField("store@email.com", text: $email)
                    .textFieldStyle(StoreTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("パスワード")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                SecureField("半角英数を含む6文字以上", text: $password)
                    .textFieldStyle(StoreTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("パスワード（確認）")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                SecureField("もう一度パスワードを入力", text: $confirmPassword)
                    .textFieldStyle(StoreTextFieldStyle())
                
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

// MARK: - ステップ 2: 焙煎士情報 ＆ アンケート
struct StoreStep2View: View {
    @Binding var roasterName: String
    @Binding var roastingExperience: String
    @Binding var roasterBio: String
    @Binding var roastingMachine: String
    
    @Binding var selectedBusinessModel: String
    @Binding var selectedRevenue: String
    @Binding var desiredPlatformFeatures: String
    @Binding var futureExpectations: String
    
    let businessModels = ["カフェ・喫茶店", "ロースタリー（焙煎所）", "スタンド・テイクアウト", "その他"]
    let revenueRanges = ["〜100万円", "100万〜300万円", "300万〜500万円", "500万円以上"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("焙煎士情報・アンケート")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            // --- 焙煎士情報セクション ---
            VStack(alignment: .leading, spacing: 16) {
                Text("焙煎士情報")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // 名前
                VStack(alignment: .leading, spacing: 8) {
                    Text("焙煎士のお名前")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    TextField("例: 焙煎 太郎", text: $roasterName)
                        .textFieldStyle(StoreTextFieldStyle())
                }
                
                // 焙煎歴
                VStack(alignment: .leading, spacing: 8) {
                    Text("焙煎歴")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    TextField("例: 5年 / 2019年〜", text: $roastingExperience)
                        .textFieldStyle(StoreTextFieldStyle())
                }
                
                // 使用焙煎機
                VStack(alignment: .leading, spacing: 8) {
                    Text("使用焙煎機")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    TextField("例: PROBAT 5kg / 富士ローヤル 1kg", text: $roastingMachine)
                        .textFieldStyle(StoreTextFieldStyle())
                }
                
                // 一言
                VStack(alignment: .leading, spacing: 8) {
                    Text("一言・こだわり（自己紹介）")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    TextField("例: 豆の個性を最大限に引き出す焙煎を心がけています", text: $roasterBio)
                        .textFieldStyle(StoreTextFieldStyle())
                }
            }
            .padding(16)
            .background(Color.black.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            
            // --- アンケートセクション ---
            VStack(alignment: .leading, spacing: 16) {
                Text("店舗アンケート")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // 業態・ビジネスモデル
                VStack(alignment: .leading, spacing: 8) {
                    Text("ビジネスモデル（業態）")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    
                    Picker("ビジネスモデル", selection: $selectedBusinessModel) {
                        Text("選択してください").tag("")
                        ForEach(businessModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // 大まかな売上
                VStack(alignment: .leading, spacing: 8) {
                    Text("大まかな月間売上（目安）")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    
                    Picker("売上", selection: $selectedRevenue) {
                        Text("選択してください").tag("")
                        ForEach(revenueRanges, id: \.self) { range in
                            Text(range).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // ECプラットフォームに望むもの
                VStack(alignment: .leading, spacing: 8) {
                    Text("現時点のECプラットフォームに望むもの")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    TextField("例: 手数料を抑えたい、使いやすいUIなど", text: $desiredPlatformFeatures)
                        .textFieldStyle(StoreTextFieldStyle())
                }
                
                // 今後期待すること
                VStack(alignment: .leading, spacing: 8) {
                    Text("今後期待すること")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                    TextField("例: 顧客とのダイレクトな繋がり", text: $futureExpectations)
                        .textFieldStyle(StoreTextFieldStyle())
                }
            }
            .padding(16)
            .background(Color.black.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - ステップ 3: 入力内容確認 ＆ 利用規約の同意
struct StoreStep3View: View {
    let storeName: String
    let fullAddress: String
    let phoneNumber: String
    let email: String
    
    let roasterName: String
    let roastingExperience: String
    let roasterBio: String
    let roastingMachine: String
    
    let businessModel: String
    let estimatedRevenue: String
    let desiredFeatures: String
    let expectations: String
    
    @Binding var isTermsAccepted: Bool
    @Binding var isPrivacyAccepted: Bool
    
    @Environment(\.openURL) var openURL
    private let termsURL = URL(string: "https://sites.google.com/d/1hgwbPGg6Dz7nm3GNFxWw_1AsttJceEXx/p/1WAmRUDO552YbIq6X9fgbQnP0p8Bln8fR/edit")!
    private let privacyURL = URL(string: "https://sites.google.com/d/1yVKs4XMg78E3NSHHxruuzdQoAKV8XsyU/p/1QYho7F0qTFM6MpUOKbeMFJvDXcHYBViv/edit")!
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("入力内容の確認")
                .font(.headline)
                .foregroundColor(.white)
            
            // 確認カード
            VStack(alignment: .leading, spacing: 12) {
                StoreConfirmRow(title: "店舗名（屋号）", value: storeName)
                Divider().background(Color.white.opacity(0.2))
                StoreConfirmRow(title: "店舗住所", value: fullAddress)
                Divider().background(Color.white.opacity(0.2))
                StoreConfirmRow(title: "電話番号", value: phoneNumber)
                Divider().background(Color.white.opacity(0.2))
                StoreConfirmRow(title: "メールアドレス", value: email)
                
                Divider().background(Color.white.opacity(0.2))
                StoreConfirmRow(title: "焙煎士のお名前", value: roasterName)
                if !roastingExperience.isEmpty {
                    Divider().background(Color.white.opacity(0.2))
                    StoreConfirmRow(title: "焙煎歴", value: roastingExperience)
                }
                if !roastingMachine.isEmpty {
                    Divider().background(Color.white.opacity(0.2))
                    StoreConfirmRow(title: "使用焙煎機", value: roastingMachine)
                }
                if !roasterBio.isEmpty {
                    Divider().background(Color.white.opacity(0.2))
                    StoreConfirmRow(title: "一言・こだわり", value: roasterBio)
                }
                
                Divider().background(Color.white.opacity(0.2))
                StoreConfirmRow(title: "ビジネスモデル", value: businessModel)
                Divider().background(Color.white.opacity(0.2))
                StoreConfirmRow(title: "月間売上目安", value: estimatedRevenue)
                
                if !desiredFeatures.isEmpty || !expectations.isEmpty {
                    Divider().background(Color.white.opacity(0.2))
                    if !desiredFeatures.isEmpty {
                        StoreConfirmRow(title: "ECに望むもの", value: desiredFeatures)
                    }
                    if !expectations.isEmpty {
                        StoreConfirmRow(title: "今後期待すること", value: expectations)
                    }
                }
            }
            .padding(16)
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            
            // 利用規約の同意セクション
            VStack(alignment: .leading, spacing: 12) {
                Text("利用規約・プライバシーポリシーの同意")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 8)

                HStack(alignment: .top, spacing: 12) {
                    Button {
                        isTermsAccepted.toggle()
                    } label: {
                        Image(systemName: isTermsAccepted ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20))
                            .foregroundColor(isTermsAccepted ? .yellow : .white.opacity(0.7))
                    }

                    Button("利用規約に同意する") {
                        openURL(termsURL)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .underline()
                }

                HStack(alignment: .top, spacing: 12) {
                    Button {
                        isPrivacyAccepted.toggle()
                    } label: {
                        Image(systemName: isPrivacyAccepted ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20))
                            .foregroundColor(isPrivacyAccepted ? .yellow : .white.opacity(0.7))
                    }

                    Button("プライバシーポリシーに同意する") {
                        openURL(privacyURL)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .underline()
                }
            }
        }
    }
}

struct StoreConfirmRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            Text(value.isEmpty ? "未入力" : value)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
        }
    }
}

// MARK: - ステップインジケーター（店舗用 全3ステップ）
struct StoreStepIndicatorView: View {
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 0) {
            StoreStepCircleView(stepNumber: 1, title: "基本・店舗情報", currentStep: currentStep)
            StoreStepLineView(isActive: currentStep > 1)
            StoreStepCircleView(stepNumber: 2, title: "焙煎士・アンケート", currentStep: currentStep)
            StoreStepLineView(isActive: currentStep > 2)
            StoreStepCircleView(stepNumber: 3, title: "確認・規約", currentStep: currentStep)
        }
        .padding(.horizontal, 16)
    }
}

struct StoreStepCircleView: View {
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
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 89/255, green: 61/255, blue: 43/255))
                } else {
                    Text("\(stepNumber)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isCurrent ? Color(red: 89/255, green: 61/255, blue: 43/255) : .white)
                }
            }
            
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(isCurrent ? .white : .white.opacity(0.6))
        }
    }
}

struct StoreStepLineView: View {
    let isActive: Bool
    
    var body: some View {
        Rectangle()
            .fill(isActive ? Color.white : Color.white.opacity(0.3))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 2)
            .offset(y: -8)
    }
}

#Preview {
    StoreSignUpView()
}
