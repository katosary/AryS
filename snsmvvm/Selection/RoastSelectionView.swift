//
//  RoastSelectionView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/19.
//


import SwiftUI

struct RoastSelectionView: View {
    @Environment(\.dismiss) private var dismiss
   
    @State private var roastSelectionviewModel = RoastSelectionViewModel()
    
    // 💡 親に値を伝えるためのクロージャ
    var onSelected: (String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("焙煎度", selection: $roastSelectionviewModel.selectedRoast) {
                    ForEach(roastSelectionviewModel.roastLevels, id: \.self) { roast in
                        Text(roast).tag(roast)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            .navigationTitle("焙煎度を選択")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        onSelected(roastSelectionviewModel.selectedRoast)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}
