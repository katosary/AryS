//
//  CountrySelectionView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/18.
//

import SwiftUI

struct CountrySelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var countrySelectionViewModel = CountrySelectionViewModel ()
    
    var onSelected: (String) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(countrySelectionViewModel.regionOrder, id: \.self) { region in
                    Section(header: Text(region)) { // ここは選択不可の見出し
                        ForEach(countrySelectionViewModel.regions[region] ?? [], id: \.self) { country in
                            Button(action: {
                                onSelected(country)
                                dismiss() // 選択したらシートを閉じる
                            }) {
                                HStack {
                                    Text(country)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if countrySelectionViewModel.country == country {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("生産国を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}
