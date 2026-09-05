//
//  StoreProductEditView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct StoreProductEditView: View {
    @State private var viewModel: StoreProductEditViewModel
    
    init(product: Product) {
        _viewModel = State(wrappedValue: StoreProductEditViewModel())
    }
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
//            // 共通パーツを呼び出す
//            StoreProductFormView(product: <#Product#>)
        }
        .navigationTitle("商品編集")
//        .sheet(isPresented: $viewModel.isShowingImagePicker) {
//            ZStack {
//                Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
//                Text("アルバム選択ビュー").foregroundColor(.white)
//            }
//        }
    }
}
