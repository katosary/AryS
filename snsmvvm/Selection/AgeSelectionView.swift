//
//  AgeSelectionView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/08.
//

import SwiftUI

struct AgeSelectionView: View {
    @State var ageSelectionViewModel: AgeSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("年齢", selection: $ageSelectionViewModel.userAge) {
                    ForEach(ageSelectionViewModel.ages, id: \.self) { age in
                        Text("\(age) 歳").tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                
                Text("選択中の年齢: \(ageSelectionViewModel.userAge) 歳")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .navigationTitle("年齢を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}
