//
//  StoreProductAddView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI
import FirebaseAuth

struct StoreProductAddView: View {
    @State private var viewModel: StoreProductAddViewModel
    @Environment(\.dismiss) private var dismiss
    
    init() {
        let emptyProduct = Product(
            storeId: Auth.auth().currentUser?.uid ?? "",
            storeName: "",
            productName: "",
            isBlend: false,
            countryName: "",
            roastLevel: "",
            price: 0,
            greenBeanCost: 0,
            packagingCost: 0,
            shippingCost: 0,
            description: "",
            imageUrl: ""
        )
        _viewModel = State(wrappedValue: StoreProductAddViewModel(product: emptyProduct))
    }
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            StoreProductFormView(viewModel: viewModel.formViewModel)
        }
        .navigationTitle("商品追加")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.saveProduct { success in
                        if success {
                            dismiss()
                        }
                    }
                }) {
                    if viewModel.isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("登録")
                            .bold()
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
    }
}
