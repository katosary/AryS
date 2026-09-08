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
    
    @State private var viewModel: StoreProfileEditViewModel
    
    init(store: Binding<Store?>) {
        self._store = store
        _viewModel = State(wrappedValue: StoreProfileEditViewModel(store: store.wrappedValue))
    }
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255)
                .ignoresSafeArea()
            
            Form {
                // 1. 店舗の紹介写真変更セクション
                Section(header: Text("店舗の紹介写真").foregroundColor(.white.opacity(0.8))) {
                    VStack(alignment: .center, spacing: 12) {
                        if let selectedImage = viewModel.selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                                .clipped()
                        } else if let urlString = viewModel.storeImageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure(_), .empty:
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
                                @unknown default:
                                    EmptyView()
                                }
                            }
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
                    VStack(alignment: .center, spacing: 12) {
                        if let selectedRoasterImage = viewModel.selectedRoasterImage {
                            Image(uiImage: selectedRoasterImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else if let urlString = viewModel.roasterImageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        PhotosPicker(selection: $viewModel.selectedRoasterPhotoItem,
                                     matching: .images,
                                     photoLibrary: .shared()) {
                            Text("写真を変更")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    
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
                        if var currentStore = store {
                            currentStore.storeName = viewModel.storeName
                            currentStore.prefecture = viewModel.prefecture
                            currentStore.roasterName = viewModel.roasterName
                            currentStore.roasterBio = viewModel.roasterBio
                            currentStore.roastingExperience = viewModel.roastingExperience
                            currentStore.roastingMachine = viewModel.roastingMachine
                            currentStore.storeImageURL = viewModel.storeImageURL
                            currentStore.roasterImageURL = viewModel.roasterImageURL
                            self.store = currentStore
                        }
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
