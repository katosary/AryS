//
//  PrefectureSelectionView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/08.
//

import SwiftUI

struct PrefectureSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PrefectureSelectionViewModel()
    
    // ② 親に値を伝えるためのクロージャ
    var onSelected: (String) -> Void
    
    var body: some View {
        NavigationStack {
            // ピッカーなどで viewModel を使用
            Picker("都道府県", selection: $viewModel.prefecture) {
                ForEach(viewModel.prefectures, id: \.self) { pref in
                    Text(pref).tag(pref)
                }
            }
            .pickerStyle(.wheel)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        onSelected(viewModel.prefecture)
                        dismiss()
                    }
                }
            }
        }
    }
}
