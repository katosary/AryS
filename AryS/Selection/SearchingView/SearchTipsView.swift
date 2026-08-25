//
//  SearchTipsView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/18.
//

import SwiftUI

struct SearchTipsView: View {
    let title: String
    @State var searchTipsViewModel = SearchTipsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List { // Listを使うとダークモード時の背景色が自動で綺麗になります
            Button(action: { searchTipsViewModel.isShowingPrefecturePicker = true }) {
                HStack {
                    Text("所在地から探す").foregroundColor(.primary)
                    Spacer()
                    Text(searchTipsViewModel.location.isEmpty ? "選択してください" : searchTipsViewModel.location)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $searchTipsViewModel.isShowingPrefecturePicker) {
                PrefectureSelectionView { selectedValue in
                    searchTipsViewModel.location = selectedValue
                }
            }
            
            Button(action: { searchTipsViewModel.isShowingCountryPicker = true }) {
                HStack {
                    Text("生産国から探す").foregroundColor(.primary)
                    Spacer()
                    Text(searchTipsViewModel.searchCountry.isEmpty ? "選択してください" : searchTipsViewModel.searchCountry)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $searchTipsViewModel.isShowingCountryPicker) {
                CountrySelectionView { selectedCountry in
                    searchTipsViewModel.searchCountry = selectedCountry
                }
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
