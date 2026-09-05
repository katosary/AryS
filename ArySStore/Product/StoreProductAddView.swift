//
//  StoreProductAddView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreProductAddView: View {
    @State private var viewModel: StoreProductAddViewModel
    
    init() {
        // 新規作成用の空のプロダクトを渡す
        let emptyProduct = Product(name: "", price: "0", roastLevel: "")
        _viewModel = State(wrappedValue: StoreProductAddViewModel())
    }
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
//            // 同じパーツをそのまま流用！
//            StoreProductFormView(product: <#Product#>)
        }
        .navigationTitle("商品追加")
//        .sheet(isPresented: $viewModel.isShowingImagePicker) {
//            ZStack {
//                Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
//                Text("アルバム選択ビュー").foregroundColor(.white)
//            }
//        }
    }
}
