//
//  StoreProductEditView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct StoreProductEditView: View {
    @State private var viewModel: StoreProductEditViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(product: Product) {
        _viewModel = State(wrappedValue: StoreProductEditViewModel(product: product))
    }
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            StoreProductFormView(viewModel: viewModel.formViewModel)
        }
        .navigationTitle("商品編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.updateProduct { success in
                        if success {
                            dismiss()
                        }
                    }
                }) {
                    if viewModel.isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("保存")
                            .bold()
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
    }
}
