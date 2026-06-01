//
//  EditSheetView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/16.
//

import SwiftUI

struct PostEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var viewModel: ViewModel
    let post: Log
    
    var body : some View {
        NavigationStack {
            Form {
                TextField("国名", text: $viewModel.editingCoffee)
                TextField("感想", text: $viewModel.editingContent, axis: .vertical)
                HStack{
                    Text("評価：")
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.editingRating)
                            .foregroundColor(number > viewModel.editingRating ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture {
                                viewModel.editingRating = number
                            }
                            .padding(.horizontal, 4)
                        
                    }
                }
            }
            .navigationTitle("投稿を編集")
            .onAppear {
                // 画面が開いたときに、元のデータをセットする
                viewModel.editingCoffee = post.countryName
                viewModel.editingRating = post.aromarating
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // ViewModelの更新関数を呼ぶ
                        viewModel.updateLog(targetPost: post)
                        dismiss()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}
