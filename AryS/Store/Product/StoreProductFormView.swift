//
//  StoreProductFormView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI
import PhotosUI

struct StoreProductFormView: View {
    @Bindable var viewModel: StoreProductFormViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                
                // --- 1. 画像スライダー ＆ アルバムボタン ---
                ZStack(alignment: .topTrailing) {
                    TabView(selection: $viewModel.currentIndex) {
                        if viewModel.productImages.isEmpty {
                            ForEach(0..<viewModel.sampleImages.count, id: \.self) { index in
                                ZStack {
                                    Color.black.opacity(0.3)
                                    Image(systemName: "cup.and.saucer.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .tag(index)
                            }
                        } else {
                            // ★修正：配列の要素を直接回すことで、インデックス範囲外エラーを完全に防止する
                            ForEach(Array(viewModel.productImages.enumerated()), id: \.offset) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipped()
                                    .tag(index)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .aspectRatio(4/3, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    
                    // アルバムボタン
                    Button {
                        viewModel.isShowingImagePicker = true
                    } label: {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(16)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- 2. 豆の種類（シングルオリジン / ブレンドの切り替え） ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("豆の種類")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Picker("豆の種類", selection: $viewModel.isBlend) {
                            Text("シングルオリジン").tag(false)
                            Text("ブレンド").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Divider().background(Color.white.opacity(0.3))
                    
                    // --- 3. タイプに応じた動的フォーム ---
                    if viewModel.isBlend {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ブレンド名（必須）")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            TextField("ブレンド名を入力", text: $viewModel.blendName)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("含まれている国（含有率の多い順）")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            
                            blendCountryPickerButton(label: "国 1", country: viewModel.blendCountry1) {
                                viewModel.activeCountryTarget = .blend1
                                viewModel.isShowingCountryPicker = true
                            }
                            blendCountryPickerButton(label: "国 2", country: viewModel.blendCountry2) {
                                viewModel.activeCountryTarget = .blend2
                                viewModel.isShowingCountryPicker = true
                            }
                            blendCountryPickerButton(label: "国 3", country: viewModel.blendCountry3) {
                                viewModel.activeCountryTarget = .blend3
                                viewModel.isShowingCountryPicker = true
                            }
                        }
                    } else {
                        Button(action: {
                            viewModel.activeCountryTarget = .single
                            viewModel.isShowingCountryPicker = true
                        }) {
                            HStack {
                                Text("生産国（必須）")
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text(viewModel.countryName.isEmpty ? "選択してください" : viewModel.countryName)
                                    .foregroundColor(viewModel.countryName.isEmpty ? .white.opacity(0.4) : .white)
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.vertical, 8)
                        }
                        Divider().background(Color.white.opacity(0.2))
                        
                        editField(label: "銘柄 / 品種", text: $viewModel.productName, placeholder: "銘柄名を入力")
                        editField(label: "農園名", text: $viewModel.farmName, placeholder: "農園名を入力")
                        editField(label: "グレード", text: $viewModel.grade, placeholder: "例: G1, AAなど")
                        
                        Button(action: { viewModel.isShowingRoastPicker = true }) {
                            HStack {
                                Text("焙煎度（必須）")
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text(viewModel.roastLevel.isEmpty ? "選択してください" : viewModel.roastLevel)
                                    .foregroundColor(viewModel.roastLevel.isEmpty ? .white.opacity(0.4) : .white)
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.vertical, 8)
                        }
                        .sheet(isPresented: $viewModel.isShowingRoastPicker) {
                            RoastSelectionView { viewModel.roastLevel = $0 }
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.3))
                    
                    // --- 4. 金額・コスト関係 ---
                    VStack(alignment: .trailing, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("価格")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            TextField("0", text: $viewModel.priceText)
                                .keyboardType(.numberPad)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.yellow)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                            Text("円")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.yellow)
                        }
                        
                        Group {
                            costRow(label: "生豆", text: $viewModel.greenBeanText)
                            costRow(label: "包装費", text: $viewModel.packagingText)
                            costRow(label: "送料", text: $viewModel.shippingText)
                            
                            HStack(spacing: 8) {
                                Text("クレジットカード決済手数料 (3.5%)")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(viewModel.calculateCreditFee())")
                                    .foregroundColor(.white)
                                Text("円")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .font(.subheadline)
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        HStack(spacing: 8) {
                            Text("利益")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(viewModel.calculateProfit())")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.green)
                            Text("円")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.3))
                    
                    // --- 5. 商品説明 ---
                    VStack(alignment: .leading, spacing: 6) {
                        Text("商品説明")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextEditor(text: $viewModel.descriptionText)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .background(Color.black.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(20)
            }
        }
        .photosPicker(isPresented: $viewModel.isShowingImagePicker, selection: $viewModel.selectedPhotoItems, matching: .images)
        .sheet(isPresented: $viewModel.isShowingCountryPicker) {
            CountrySelectionView { selectedCountry in
                switch viewModel.activeCountryTarget {
                case .single: viewModel.countryName = selectedCountry
                case .blend1: viewModel.blendCountry1 = selectedCountry
                case .blend2: viewModel.blendCountry2 = selectedCountry
                case .blend3: viewModel.blendCountry3 = selectedCountry
                }
            }
        }
    }
    
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.6))
            TextField(placeholder, text: text)
                .foregroundColor(.white)
                .padding(.vertical, 8)
            Divider().background(Color.white.opacity(0.2))
        }
    }
    
    @ViewBuilder
    private func blendCountryPickerButton(label: String, country: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label).foregroundColor(.white.opacity(0.8))
                Spacer()
                Text(country.isEmpty ? "選択してください" : country)
                    .foregroundColor(country.isEmpty ? .white.opacity(0.4) : .white)
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.white.opacity(0.6))
            }
            .padding(.vertical, 6)
        }
    }
    
    @ViewBuilder
    private func costRow(label: String, text: Binding<String>) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text("円")
                .foregroundColor(.white.opacity(0.7))
        }
    }
}
