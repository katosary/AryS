//
//  StoreProfileEditView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/07.
//

import SwiftUI
import PhotosUI

struct StoreProfileEditView: View {
    @Binding var store: Store?
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: StoreProfileEditViewModel
    
    // イニシャライザでViewModelを初期化
    init(store: Binding<Store?>) {
        self._store = store
        _viewModel = StateObject(wrappedValue: StoreProfileEditViewModel(store: store.wrappedValue))
    }
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255)
                .ignoresSafeArea()
            
            Form {
                // 1. 店舗の紹介写真変更セクション
                Section(header: Text("店舗の紹介写真").foregroundColor(.white.opacity(0.8))) {
                    VStack(alignment: .center, spacing: 12) {
                        // 選択された画像、または既存のプレビュー表示
                        if let selectedImage = viewModel.selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                                .clipped()
                        } else {
                            ZStack {
                                Color.black.opacity(0.3)
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 30))
                                    Text("写真を選択してください")
                                        .font(.caption)
                                }
                                .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(height: 180)
                            .cornerRadius(12)
                        }
                        
                        // フォトライブラリを開くピッカー
                        PhotosPicker(selection: $viewModel.selectedPhotoItem,
                                     matching: .images,
                                     photoLibrary: .shared()) {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                Text("フォトライブラリから選択")
                            }
                            .font(.subheadline)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                
                // 2. 店舗基本情報セクション
                Section(header: Text("店舗基本情報").foregroundColor(.white.opacity(0.8))) {
                    TextField("店舗名", text: $viewModel.storeName)
                    TextField("都道府県", text: $viewModel.prefecture)
                }
                .listRowBackground(Color.black.opacity(0.3))
                
                // 3. 焙煎士情報セクション
                Section(header: Text("焙煎士情報").foregroundColor(.white.opacity(0.8))) {
                    TextField("焙煎士の名前", text: $viewModel.roasterName)
                    TextField("焙煎歴 (例: 5年)", text: $viewModel.roastingExperience)
                    TextField("使用焙煎機", text: $viewModel.roastingMachine)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("一言・こだわり（自己紹介）")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        TextEditor(text: $viewModel.roasterBio)
                            .frame(height: 100)
                            .scrollContentBackground(.hidden)
                    }
                }
                .listRowBackground(Color.black.opacity(0.3))
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("プロフィール編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    viewModel.saveStore {
                        // 保存成功時にバインド元のstoreを更新して画面を閉じる
                        self.store = viewModel.storeObjectForBinding() // または直接反映
                        dismiss()
                    }
                }
                .bold()
                .foregroundColor(.white)
                .disabled(viewModel.isSaving)
            }
        }
        .preferredColorScheme(.dark)
    }
}
