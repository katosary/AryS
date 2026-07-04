//
//  EditSheetView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/16.
//

import SwiftUI

struct PostEditView: View {
    @State var editCoffeeLogViewModel: EditCoffeeLogViewModel
    let post: Log
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("国名", text: $editCoffeeLogViewModel.editingCoffee)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("感想", text: $editCoffeeLogViewModel.editingContent, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 100, alignment: .top)
                    
                    HStack {
                        Text("評価：")
                        ForEach(1...editCoffeeLogViewModel.maxRating, id: \.self) { number in
                            editCoffeeLogViewModel.image(for: number, rating: editCoffeeLogViewModel.editingRating)
                                .foregroundColor(number > editCoffeeLogViewModel.editingRating ? editCoffeeLogViewModel.offColor : editCoffeeLogViewModel.onColor)
                                .onTapGesture {
                                    editCoffeeLogViewModel.editingRating = number
                                }
                                .padding(.horizontal, 4)
                        }
                    }
                }
                .padding() // 画面端に余白を作る
            }
            .navigationTitle("投稿を編集")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        editCoffeeLogViewModel.updateLog(targetPost: post)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}
