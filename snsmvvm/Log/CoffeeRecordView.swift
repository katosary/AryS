//
//  CoffeeRecordView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct CoffeeRecordView: View {
    @State var coffeeRecordViewModel = CoffeeRecordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    infoSection()
                    photoSection()
                    aromaSection()
                    tasteSection()
                    submitButton()
                }
                .padding()
            }
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private func infoSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("基本情報").font(.headline)
            editField(label: "店舗名", text: $coffeeRecordViewModel.shopName, placeholder: "店舗名を入力")
            editField(label: "農園名", text: $coffeeRecordViewModel.farmName, placeholder: "農園名を入力")
            
            // 生産国選択
            Button(action: { coffeeRecordViewModel.isShowingCountryPicker = true }) {
                HStack {
                    Text("生産国").foregroundColor(.primary)
                    Spacer()
                    Text(coffeeRecordViewModel.countryName.isEmpty ? "選択してください" : coffeeRecordViewModel.countryName)
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $coffeeRecordViewModel.isShowingCountryPicker) {
                CountrySelectionView { selectedCountry in
                    coffeeRecordViewModel.countryName = selectedCountry
                }
            }
            
            // 焙煎度選択
            Button(action: { coffeeRecordViewModel.isShowingRoastPicker = true }) {
                HStack {
                    Text("焙煎度").foregroundColor(.primary)
                    Spacer()
                    Text(coffeeRecordViewModel.roastLevel.isEmpty ? "選択してください" : coffeeRecordViewModel.roastLevel)
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $coffeeRecordViewModel.isShowingRoastPicker) {
                RoastSelectionView { selectedRoast in
                    coffeeRecordViewModel.roastLevel = selectedRoast
                }
            }
        }
    }
    
    @ViewBuilder
    private func photoSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("写真").font(.headline)
            ZStack {
                if let firstImage = coffeeRecordViewModel.logImages.first {
                    Image(uiImage: firstImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 200)
                        .overlay(Text("写真が選択されていません").foregroundColor(.secondary))
                }
            }
            PhotosPicker(selection: $coffeeRecordViewModel.selectedItems, maxSelectionCount: 1, matching: .images) {
                Label(coffeeRecordViewModel.logImages.isEmpty ? "画像を選択" : "画像を変更", systemImage: "photo.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    @ViewBuilder
    private func aromaSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("香り").font(.headline)
            HStack {
                Text("強さ").frame(width: 50)
                Spacer()
                ForEach(1...coffeeRecordViewModel.maxRating, id: \.self) { number in
                    coffeeRecordViewModel.image(for: number, rating: coffeeRecordViewModel.aromarating)
                        .font(.system(size: 24))
                        .foregroundColor(number > coffeeRecordViewModel.aromarating ? coffeeRecordViewModel.offColor : coffeeRecordViewModel.onColor)
                        .onTapGesture { coffeeRecordViewModel.aromarating = number }
                }
            }
            TextField("どんな香りでしたか？", text: $coffeeRecordViewModel.aromaComment)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    @ViewBuilder
    private func tasteSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("味わいの評価").font(.headline)
            
            // 総合評価として3つの項目を並べる
            VStack(spacing: 15) {
                ratingRow(label: "苦味", rating: $coffeeRecordViewModel.bitternessrating)
                ratingRow(label: "酸味", rating: $coffeeRecordViewModel.acidityrating)
                ratingRow(label: "コク", rating: $coffeeRecordViewModel.bodyrating)
            }
        }
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func ratingRow(label: String, rating: Binding<Int>) -> some View {
        HStack {
            Text(label).frame(width: 50)
            Spacer()
            ForEach(1...coffeeRecordViewModel.maxRating, id: \.self) { number in
                coffeeRecordViewModel.image(for: number, rating: rating.wrappedValue)
                    .font(.system(size: 24))
                    .foregroundColor(number > rating.wrappedValue ? coffeeRecordViewModel.offColor : coffeeRecordViewModel.onColor)
                    .onTapGesture { rating.wrappedValue = number }
            }
        }
    }
    
    @ViewBuilder
    private func submitButton() -> some View {
        Button {
            if let currentUser = Auth.auth().currentUser {
                coffeeRecordViewModel.uploadAndSaveLog(currentUser: currentUser) { success in
                    if success { dismiss() }
                }
            }
        } label: {
            Text("投稿する")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(coffeeRecordViewModel.aromarating == 0 ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Text(label).frame(width: 80, alignment: .leading)
            TextField(placeholder, text: text)
        }
        Divider()
    }
}
