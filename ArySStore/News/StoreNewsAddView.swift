//
//  StoreNewsAddView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreNewsAddView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel = StoreNewsFormViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    StoreNewsFormView(viewModel: viewModel)
                    
                    // 配信するボタン
                    Button {
                        viewModel.saveNews {
                            dismiss()
                        }
                    } label: {
                        Text("NEWSを配信する")
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
            .navigationTitle("新しいNEWSを追加")
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
