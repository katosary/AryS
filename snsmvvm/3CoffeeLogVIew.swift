//
//  SendMessageView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import SwiftUI
import PhotosUI

struct PostSendView: View {
    @State var viewModel = ViewModel()
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep: Int = 0
    private let totalSteps = 5
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 進捗バー
                ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                    .padding()
                
                TabView(selection: $currentStep) {
                    // --- STEP 1: 情報入力 ---
                    stepInfoPage()
                        .tag(0)
                    
                    // --- STEP 2: 画像選択 ---
                    stepPhotoPage()
                        .tag(1)
                    
                    // --- STEP 3: 香り評価 ---
                    stepAromaPage()
                        .tag(2)
                    
                    // --- STEP 4: １口目評価 ---
                    stepFirstPage()
                        .tag(3)
                    // --- STEP 5: ２口目評価 ---
                    stepSecondPage()
                        .tag(4)
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // --- ナビゲーションボタン ---
                navigationControls()
            }
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - 各ページを ViewBuilder で分離（エラー回避の肝）
    
    @ViewBuilder
    private func stepInfoPage() -> some View {
        VStack(spacing: 20) {
            Text("これから飲むコーヒーのことを教えてください").font(.headline)
            TextField("店舗名", text: $viewModel.shopName)
                .textFieldStyle(.roundedBorder)
            TextField("国名", text: $viewModel.countryName)
                .textFieldStyle(.roundedBorder)
            TextField("農園名", text: $viewModel.farmName)
                .textFieldStyle(.roundedBorder)
            TextField("焙煎度", text: $viewModel.roastLevel)
                .textFieldStyle(.roundedBorder)
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepPhotoPage() -> some View {
        VStack(spacing: 20) {
            Text("目の前のコーヒーの写真を撮ってください").font(.headline)
            if let image = viewModel.logImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 250)
                    .overlay(Image(systemName: "photo").font(.largeTitle))
            }
            
            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                Label(viewModel.logImage == nil ? "画像を選択" : "画像を変更", systemImage: "photo")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepAromaPage() -> some View {
        VStack(spacing: 30) {
            Text("STEP１. 香りを楽しみましょう").font(.headline)
            VStack {
                Text("香りは感じましたか？").padding(5)
                HStack {
                    Text("弱い").padding(5)
                    HStack {
                        ForEach(1...viewModel.maxRating, id: \.self) { number in
                            viewModel.image(for: number, rating: viewModel.aromarating)
                                .font(.system(size: 30))
                                .foregroundColor(number > viewModel.aromarating ? viewModel.offColor : viewModel.onColor)
                                .onTapGesture { viewModel.aromarating = number }
                        }
                    }
                    Text("強い").padding(5)
                }
                Text("どんな香りでしたか？\n(任意)").padding(10)
                TextField("", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
            }
            Divider()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepFirstPage() -> some View {
        VStack(spacing: 30) {
            Text("STEP2. １口目の感想を教えてください").font(.headline)
            HStack {
                Text("苦味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bitternessrating1)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bitternessrating1 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bitternessrating1 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("酸味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.acidityrating1)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.acidityrating1 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.acidityrating1 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("コク")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bodyrating1)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bodyrating1 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bodyrating1 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepSecondPage() -> some View {
        VStack(spacing: 30) {
            Text("STEP3. 2口目の感想を教えてください").font(.headline)
            HStack {
                Text("苦味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bitternessrating2)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bitternessrating2 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bitternessrating2 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("酸味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.acidityrating2)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.acidityrating2 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.acidityrating2 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("コク")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bodyrating2)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bodyrating2 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bodyrating2 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
             //---投稿ボタン　※最後のページに貼り付ける ---
            Button {
                viewModel.addLog(currentUser: profileViewModel.user)
                viewModel.aromarating = 0
                dismiss()
            } label: {
                Text("この内容で投稿する")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.aromarating == 0 ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.aromarating == 0)
            Spacer()

        }
        .padding()
        
    }
    
    @ViewBuilder
    private func navigationControls() -> some View {
        HStack {
            if currentStep > 0 {
                Button("戻る") {
                    withAnimation { currentStep -= 1 }
                }
            }
            Spacer()
            if currentStep < totalSteps - 1 {
                Button("次へ") {
                    withAnimation { currentStep += 1 }
                }
                .buttonStyle(.borderedProminent)
                .disabled(currentStep == 0 && viewModel.countryName.isEmpty)
            }
        }
        .padding()
    }
}

