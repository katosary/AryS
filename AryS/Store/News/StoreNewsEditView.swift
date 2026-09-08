//
//  StoreNewsEditView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreNewsEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: StoreNewsEditViewModel
    
    init(viewModel: StoreNewsEditViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            // フォームのみを配置（下部の独自ボタンは撤去）
            StoreNewsFormView(viewModel: viewModel.formViewModel)
        }
        .navigationTitle("NEWSを編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 右上に保存ボタンを配置
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.updateNews { success in
                        if success { dismiss() }
                    }
                }) {
                    if viewModel.isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("保存")
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
    }
}
