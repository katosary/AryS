//
//  SearchFilterViewView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/18.
//

import SwiftUI

struct SearchFilterView: View {
    let title: String
    @State var searchFilterViewModel = SearchFilterViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            // 所在地から探す
            Button(action: { searchFilterViewModel.isShowingPrefecturePicker = true }) {
                HStack {
                    Text("所在地から探す").foregroundColor(.primary)
                    Spacer()
                    Text(searchFilterViewModel.location.isEmpty ? "選択してください" : searchFilterViewModel.location)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $searchFilterViewModel.isShowingPrefecturePicker) {
                PrefectureSelectionView { selectedValue in
                    searchFilterViewModel.location = selectedValue
                }
            }
             
            // 生産国から探す
            Button(action: { searchFilterViewModel.isShowingCountryPicker = true }) {
                HStack {
                    Text("生産国から探す").foregroundColor(.primary)
                    Spacer()
                    Text(searchFilterViewModel.searchCountry.isEmpty ? "選択してください" : searchFilterViewModel.searchCountry)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $searchFilterViewModel.isShowingCountryPicker) {
                CountrySelectionView { selectedCountry in
                    searchFilterViewModel.searchCountry = selectedCountry
                }
            }
            
            // 💡 評価レンジスライダーのセクション
            Section(header: Text("評価で絞り込む")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("評価レンジ")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(String(format: "%.1f", searchFilterViewModel.minRating)) 〜 \(String(format: "%.1f", searchFilterViewModel.maxRating))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 先ほどのコーヒー豆レンジスライダーを埋め込み
                    CoffeeBeanRangeSliderView(
                        lowerRating: $searchFilterViewModel.minRating,
                        upperRating: $searchFilterViewModel.maxRating
                    )
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完了") { dismiss() }
            }
        }
    }
}
