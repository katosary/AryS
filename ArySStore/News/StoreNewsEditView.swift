//
//  StoreNewsEditView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreNewsEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: StoreNewsFormViewModel
    
    init(viewModel: StoreNewsFormViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    StoreNewsFormView(viewModel: viewModel)
                    
                    // 変更を保存するボタン
                    Button {
                        viewModel.saveNews {
                            dismiss()
                        }
                    } label: {
                        Text("変更を保存する")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("NEWSを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
