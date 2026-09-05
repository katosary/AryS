////
////  StoreSignUpView.swift
////  snsmvvm
////
////  Created by katoso on 2026/09/02.
////
//
//import SwiftUI
//
//struct StoreSignUpView: View {
//    @State var viewModel = StoreSignUpViewModel()
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                viewModel.brandBackgroundColor
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    // --- ステップインジケーター（店舗用 全4ステップ） ---
//                    StoreStepIndicatorView(currentStep: viewModel.currentStep)
//                        .padding(.vertical, 20)
//                    
//                    ScrollView {
//                        VStack(alignment: .leading, spacing: 24) {
//                            
//                            Text("店舗アカウントの作成")
//                                .font(.system(size: 24, weight: .bold))
//                                .foregroundColor(.white)
//                            
//                            // --- 各ステップのコンテンツ ---
//                            switch viewModel.currentStep {
//                            case 1:
//                                StoreStep1View(
//                                    email: $viewModel.email,
//                                    password: $viewModel.password,
//                                    confirmPassword: $viewModel.confirmPassword
//                                )
//                            case 2:
//                                StoreStep2View(
//                                    storeName: $viewModel.storeName,
//                                    prefecture: $viewModel.prefecture,
//                                    addressDetail: $viewModel.addressDetail,
//                                    phoneNumber: $viewModel.phoneNumber,
//                                    isShowingPrefecturePicker: $viewModel.isShowingPrefecturePicker
//                                )
//                            case 3:
//                                StoreStep3View(
//                                    selectedCoffeeGenre: $viewModel.selectedCoffeeGenre,
//                                    selectedBusinessModel: $viewModel.selectedBusinessModel,
//                                    freeComment: $viewModel.freeComment
//                                )
//                            case 4:
//                                StoreStep4View(
//                                    email: viewModel.email,
//                                    storeName: viewModel.storeName,
//                                    fullAddress: "\(viewModel.prefecture) \(viewModel.addressDetail)",
//                                    phoneNumber: viewModel.phoneNumber,
//                                    coffeeGenre: viewModel.selectedCoffeeGenre,
//                                    businessModel: viewModel.selectedBusinessModel,
//                                    isTermsAccepted: $viewModel.isTermsAccepted,
//                                    isPrivacyAccepted: $viewModel.isPrivacyAccepted
//                                )
//                            default:
//                                EmptyView()
//                            }
//                            
//                            if !viewModel.errorMessage.isEmpty {
//                                Text(viewModel.errorMessage)
//                                    .foregroundColor(.yellow)
//                                    .font(.caption)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                            }
//                            
//                            // --- 「次へ」または「登録する」ボタン ---
//                            Button {
//                                if viewModel.currentStep < 4 {
//                                    viewModel.nextStep()
//                                } else {
//                                    viewModel.registerStore {
//                                        // 登録成功時の処理
//                                    }
//                                }
//                            } label: {
//                                Group {
//                                    if viewModel.isLoading {
//                                        ProgressView()
//                                            .tint(viewModel.brandBackgroundColor)
//                                    } else {
//                                        Text(viewModel.currentStep == 4 ? "登録する" : "次へ")
//                                            .font(.headline)
//                                            .bold()
//                                    }
//                                }
//                                .foregroundColor(viewModel.brandBackgroundColor)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 14)
//                                .background(!viewModel.isCurrentStepValid() || viewModel.isLoading ? Color.white.opacity(0.5) : Color.white)
//                                .cornerRadius(8)
//                                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
//                            }
//                            .disabled(!viewModel.isCurrentStepValid() || viewModel.isLoading)
//                            .padding(.top, 12)
//                            
//                            // --- 「戻る」ボタン ---
//                            Button {
//                                if viewModel.currentStep > 1 {
//                                    viewModel.previousStep()
//                                } else {
//                                    dismiss()
//                                }
//                            } label: {
//                                HStack(spacing: 4) {
//                                    Image(systemName: "chevron.left")
//                                    Text("戻る")
//                                }
//                                .font(.subheadline)
//                                .foregroundColor(.white.opacity(0.8))
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 8)
//                            }
//                            .disabled(viewModel.isLoading)
//                        }
//                        .padding(.horizontal, 24)
//                        .padding(.bottom, 32)
//                    }
//                    .id(viewModel.currentStep)
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("ログイン画面に戻る") {
//                        dismiss()
//                    }
//                    .font(.subheadline)
//                    .foregroundColor(.white)
//                    .disabled(viewModel.isLoading)
//                }
//            }
//            .alert("確認メールを送信しました", isPresented: $viewModel.showVerificationAlert) {
//                Button("OK") {
//                    dismiss()
//                }
//            } message: {
//                Text("ご登録いただいた店舗メールアドレス宛に確認メールを送信しました。メール内のリンクをクリックして認証を完了させてください。")
//            }
//        }
//        .preferredColorScheme(.dark)
//        .tint(.white)
//    }
//}
//
//// MARK: - ステップ 1: 基本情報（メール・パスワード）
//struct StoreStep1View: View {
//    @Binding var email: String
//    @Binding var password: String
//    @Binding var confirmPassword: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            VStack(alignment: .leading, spacing: 8) {
//                Text("店舗メールアドレス")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                TextField("store@email.com", text: $email)
//                    .textFieldStyle(StoreTextFieldStyle())
//                    .autocapitalization(.none)
//                    .keyboardType(.emailAddress)
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("パスワード")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                SecureField("半角英数を含む6文字以上", text: $password)
//                    .textFieldStyle(StoreTextFieldStyle())
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("パスワード（確認）")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                SecureField("もう一度パスワードを入力", text: $confirmPassword)
//                    .textFieldStyle(StoreTextFieldStyle())
//                
//                if !confirmPassword.isEmpty {
//                    if password == confirmPassword {
//                        Text("パスワードが一致しています")
//                            .font(.caption2)
//                            .foregroundColor(.green)
//                    } else {
//                        Text("パスワードが一致していません")
//                            .font(.caption2)
//                            .foregroundColor(.yellow)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - ステップ 2: 店舗情報（屋号・住所・電話番号）
//struct StoreStep2View: View {
//    @Binding var storeName: String
//    @Binding var prefecture: String
//    @Binding var addressDetail: String
//    @Binding var phoneNumber: String
//    @Binding var isShowingPrefecturePicker: Bool
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            VStack(alignment: .leading, spacing: 8) {
//                Text("店舗名（屋号）")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                TextField("例: カフェ・サンプル", text: $storeName)
//                    .textFieldStyle(StoreTextFieldStyle())
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("都道府県")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                
//                Button(action: { isShowingPrefecturePicker = true }) {
//                    HStack {
//                        Text(prefecture.isEmpty ? "都道府県を選択してください" : prefecture)
//                            .foregroundColor(prefecture.isEmpty ? .white.opacity(0.4) : .white)
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .font(.caption)
//                            .foregroundColor(.white.opacity(0.6))
//                    }
//                    .padding(12)
//                    .background(Color.black.opacity(0.2))
//                    .cornerRadius(8)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                    )
//                }
////                .sheet(isPresented: $isShowingPrefecturePicker) {
////                    PrefectureSelectionView { selectedPrefecture in
////                        prefecture = selectedPrefecture
////                    }
////                    .presentationDetents([.medium])
////                }
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("市区町村・番地・ビル名")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                TextField("例: 渋谷区1-2-3 カフェビル1F", text: $addressDetail)
//                    .textFieldStyle(StoreTextFieldStyle())
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("店舗電話番号")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                TextField("例: 03-0000-0000", text: $phoneNumber)
//                    .textFieldStyle(StoreTextFieldStyle())
//                    .keyboardType(.phonePad)
//            }
//        }
//    }
//}
//
//// MARK: - ステップ 3: アンケート
//struct StoreStep3View: View {
//    @Binding var selectedCoffeeGenre: String
//    @Binding var selectedBusinessModel: String
//    @Binding var freeComment: String
//    
//    let coffeeGenres = ["スペシャルティコーヒー", "自家焙煎", "深煎り・喫茶店", "浅煎り・サードウェーブ", "その他"]
//    let businessModels = ["カフェ・喫茶店", "ロースタリー（焙煎所）", "スタンド・テイクアウト", "その他"]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("店舗に関する簡単なアンケート（任意）")
//                .font(.subheadline)
//                .foregroundColor(.white.opacity(0.8))
//            
//            // 質問1
//            VStack(alignment: .leading, spacing: 8) {
//                Text("主なコーヒーのジャンル・特徴")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                
//                Picker("ジャンル", selection: $selectedCoffeeGenre) {
//                    Text("選択してください").tag("")
//                    ForEach(coffeeGenres, id: \.self) { genre in
//                        Text(genre).tag(genre)
//                    }
//                }
//                .pickerStyle(.menu)
//                .padding(8)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color.black.opacity(0.2))
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                )
//            }
//            
//            // 質問2
//            VStack(alignment: .leading, spacing: 8) {
//                Text("業態・スタイル")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                
//                Picker("業態", selection: $selectedBusinessModel) {
//                    Text("選択してください").tag("")
//                    ForEach(businessModels, id: \.self) { model in
//                        Text(model).tag(model)
//                    }
//                }
//                .pickerStyle(.menu)
//                .padding(8)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color.black.opacity(0.2))
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                )
//            }
//            
//            // 質問3
//            VStack(alignment: .leading, spacing: 8) {
//                Text("アプリに期待すること・自由記入")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                
//                TextField("例：コーヒー好きなお客様と繋がりを作りたい", text: $freeComment)
//                    .textFieldStyle(StoreTextFieldStyle())
//            }
//        }
//    }
//}
//
//// MARK: - ステップ 4: 入力内容確認 ＆ 利用規約の同意
//struct StoreStep4View: View {
//    let email: String
//    let storeName: String
//    let fullAddress: String
//    let phoneNumber: String
//    let coffeeGenre: String
//    let businessModel: String
//    
//    @Binding var isTermsAccepted: Bool
//    @Binding var isPrivacyAccepted: Bool
//    
//    @Environment(\.openURL) var openURL
//    private let termsURL = URL(string: "https://sites.google.com/d/1hgwbPGg6Dz7nm3GNFxWw_1AsttJceEXx/p/1WAmRUDO552YbIq6X9fgbQnP0p8Bln8fR/edit")!
//    private let privacyURL = URL(string: "https://sites.google.com/d/1yVKs4XMg78E3NSHHxruuzdQoAKV8XsyU/p/1QYho7F0qTFM6MpUOKbeMFJvDXcHYBViv/edit")!
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("入力内容の確認")
//                .font(.headline)
//                .foregroundColor(.white)
//            
//            // 確認カード
//            VStack(alignment: .leading, spacing: 12) {
//                StoreConfirmRow(title: "メールアドレス", value: email)
//                Divider().background(Color.white.opacity(0.2))
//                StoreConfirmRow(title: "店舗名（屋号）", value: storeName)
//                Divider().background(Color.white.opacity(0.2))
//                StoreConfirmRow(title: "店舗住所", value: fullAddress)
//                Divider().background(Color.white.opacity(0.2))
//                StoreConfirmRow(title: "電話番号", value: phoneNumber)
//                
//                if !coffeeGenre.isEmpty || !businessModel.isEmpty {
//                    Divider().background(Color.white.opacity(0.2))
//                    if !coffeeGenre.isEmpty {
//                        StoreConfirmRow(title: "コーヒー特徴", value: coffeeGenre)
//                    }
//                    if !businessModel.isEmpty {
//                        StoreConfirmRow(title: "業態", value: businessModel)
//                    }
//                }
//            }
//            .padding(16)
//            .background(Color.black.opacity(0.2))
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
//            )
//            
//            // 利用規約の同意セクション
//            VStack(alignment: .leading, spacing: 12) {
//                Text("利用規約・プライバシーポリシーの同意")
//                    .font(.subheadline)
//                    .bold()
//                    .foregroundColor(.white)
//                    .padding(.top, 8)
//
//                // 利用規約
//                HStack(alignment: .top, spacing: 12) {
//                    Button {
//                        isTermsAccepted.toggle()
//                    } label: {
//                        Image(systemName: isTermsAccepted ? "checkmark.square.fill" : "square")
//                            .font(.system(size: 20))
//                            .foregroundColor(isTermsAccepted ? .yellow : .white.opacity(0.7))
//                    }
//
//                    Button("利用規約に同意する") {
//                        openURL(termsURL)
//                    }
//                    .font(.subheadline)
//                    .foregroundColor(.white)
//                    .underline()
//                }
//
//                // プライバシーポリシー
//                HStack(alignment: .top, spacing: 12) {
//                    Button {
//                        isPrivacyAccepted.toggle()
//                    } label: {
//                        Image(systemName: isPrivacyAccepted ? "checkmark.square.fill" : "square")
//                            .font(.system(size: 20))
//                            .foregroundColor(isPrivacyAccepted ? .yellow : .white.opacity(0.7))
//                    }
//
//                    Button("プライバシーポリシーに同意する") {
//                        openURL(privacyURL)
//                    }
//                    .font(.subheadline)
//                    .foregroundColor(.white)
//                    .underline()
//                }
//            }
//        }
//    }
//}
//
//struct StoreConfirmRow: View {
//    let title: String
//    let value: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.white.opacity(0.6))
//            Text(value.isEmpty ? "未入力" : value)
//                .font(.subheadline)
//                .bold()
//                .foregroundColor(.white)
//        }
//    }
//}
//
//
//// MARK: - ステップインジケーター（店舗用 全4ステップ）
//struct StoreStepIndicatorView: View {
//    let currentStep: Int
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            StoreStepCircleView(stepNumber: 1, title: "アカウント", currentStep: currentStep)
//            StoreStepLineView(isActive: currentStep > 1)
//            StoreStepCircleView(stepNumber: 2, title: "店舗情報", currentStep: currentStep)
//            StoreStepLineView(isActive: currentStep > 2)
//            StoreStepCircleView(stepNumber: 3, title: "アンケート", currentStep: currentStep)
//            StoreStepLineView(isActive: currentStep > 3)
//            StoreStepCircleView(stepNumber: 4, title: "確認・規約", currentStep: currentStep)
//        }
//        .padding(.horizontal, 16)
//    }
//}
//
//struct StoreStepCircleView: View {
//    let stepNumber: Int
//    let title: String
//    let currentStep: Int
//    
//    var isCompleted: Bool { currentStep > stepNumber }
//    var isCurrent: Bool { currentStep == stepNumber }
//    
//    var body: some View {
//        VStack(spacing: 4) {
//            ZStack {
//                Circle()
//                    .fill(isCompleted || isCurrent ? Color.white : Color.white.opacity(0.3))
//                    .frame(width: 24, height: 24)
//                
//                if isCompleted {
//                    Image(systemName: "checkmark")
//                        .font(.system(size: 10, weight: .bold))
//                        .foregroundColor(Color(red: 89/255, green: 61/255, blue: 43/255))
//                } else {
//                    Text("\(stepNumber)")
//                        .font(.system(size: 10, weight: .bold))
//                        .foregroundColor(isCurrent ? Color(red: 89/255, green: 61/255, blue: 43/255) : .white)
//                }
//            }
//            
//            Text(title)
//                .font(.system(size: 9))
//                .foregroundColor(isCurrent ? .white : .white.opacity(0.6))
//        }
//    }
//}
//
//struct StoreStepLineView: View {
//    let isActive: Bool
//    
//    var body: some View {
//        Rectangle()
//            .fill(isActive ? Color.white : Color.white.opacity(0.3))
//            .frame(height: 2)
//            .frame(maxWidth: .infinity)
//            .padding(.horizontal, 2)
//            .offset(y: -8)
//    }
//}
//
//
//#Preview {
//    StoreSignUpView()
//}
