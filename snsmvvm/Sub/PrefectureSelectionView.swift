//
//  PrefectureSelectionView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/08.
//

import SwiftUI

struct PrefectureSelectionView: View {
    @State var prefectureSelectionViewModel: PrefectureSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                // ドラムロール形式のピッカー
                Picker("都道府県", selection: $prefectureSelectionViewModel.prefecture) {
                    ForEach(prefectureSelectionViewModel.prefectures, id: \.self) { pref in
                        // pref は「東京都」などの文字列。そのまま表示し、tagにも文字列を渡す
                        Text(pref).tag(pref)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden() // 中央に配置
                
                Text("選択中: \(prefectureSelectionViewModel.prefecture.isEmpty ? "未選択" : prefectureSelectionViewModel.prefecture)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .navigationTitle("都道府県を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
        // 年齢と同じくハーフモーダルで表示
        .presentationDetents([.height(300)])
    }
}
