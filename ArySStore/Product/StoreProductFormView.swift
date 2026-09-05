//
//  StoreProductFormView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct StoreProductFormView: View {
    @State private var viewModel: StoreProductFormViewModel
    
    init(product: Product) {
        _viewModel = State(wrappedValue: StoreProductFormViewModel(product: product))
    }
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // --- 1. 一番上の画像スライダー（横4：縦3）＆ 右上のアルバムボタン ---
                    ZStack(alignment: .topTrailing) {
                        TabView(selection: $viewModel.currentIndex) {
                            ForEach(0..<viewModel.sampleImages.count, id: \.self) { index in
                                ZStack {
                                    Color.black.opacity(0.3)
                                    Image(systemName: "cup.and.saucer.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .aspectRatio(4/3, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        
                        // 右上の丸いアルバムボタン
                        Button {
                            viewModel.isShowingImagePicker = true
                        } label: {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .padding(16)
                        
                        // 現在地インジケーター（右下）
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(viewModel.currentIndex + 1) / \(viewModel.sampleImages.count)")
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(12)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // --- 2. 商品名（大きめ・左詰め） ---
                        VStack(alignment: .leading, spacing: 4) {
                            Text("商品名")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            TextField("商品名を入力", text: $viewModel.productName)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // --- 3. お金関係（全体を右寄せ・ラベルと円を揃える） ---
                        VStack(alignment: .trailing, spacing: 12) {
                            
                            // 価格（ちょっと大きめ・編集可能）
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
                            
                            // 原価グループ（編集可能）
                            Group {
                                costRow(label: "生豆", text: $viewModel.greenBeanText)
                                costRow(label: "包装費", text: $viewModel.packagingText)
                                costRow(label: "送料", text: $viewModel.shippingText)
                                
                                // クレジットカード決済手数料（自動計算・3.5% = 0.035）
                                HStack(spacing: 8) {
                                    Text("クレジットカード決済手数料")
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text("\(viewModel.calculateCreditFee())")
                                        .foregroundColor(.white)
                                        .frame(width: 80, alignment: .trailing)
                                    Text("円")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .font(.subheadline)
                            
                            // 値段の下の線
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                                .padding(.vertical, 4)
                            
                            // 利益（自動計算表示）
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
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // --- 4. 説明欄（大きめ） ---
                        VStack(alignment: .leading, spacing: 6) {
                            Text("商品説明")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            TextEditor(text: $viewModel.descriptionText)
                                .frame(minHeight: 150)
                                .scrollContentBackground(.hidden)
                                .background(Color.black.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            ZStack {
                Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
                Text("アルバム選択ビュー（ここにPHPicker等が入ります）")
                    .foregroundColor(.white)
            }
        }
    }
    
    // 費用項目の共通レイアウト用ヘルパー
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

// MARK: - プレビュー
#Preview {
    StoreProductFormView(product: Product(name: "秋限定ブレンド", price: "680円", roastLevel: ""))
        .preferredColorScheme(.dark)
}
