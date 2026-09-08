//
//  StoreNewsAddView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreNewsAddView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = StoreNewsAddViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                StoreNewsFormView(viewModel: viewModel.formViewModel)
            }
        }
        .navigationTitle("新しいNEWSを追加")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    viewModel.addNews { success in
                        if success { dismiss() }
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("配信")
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
    }
}
