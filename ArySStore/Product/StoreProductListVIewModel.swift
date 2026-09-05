//
//  StoreProductListViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import Foundation

@Observable
class StoreProductListViewModel {
    var products: [Product] = [
        Product(name: "エチオピア イルガチェフェ 浅煎り", price: "1,200円", roastLevel: "浅煎り"),
        Product(name: "ブラジル サントス 深煎り", price: "980円", roastLevel: "深煎り"),
        Product(name: "コスタリカ ハニー製法 中煎り", price: "1,100円", roastLevel: "中煎り")
    ]
    
    var isShowingAddView = false

    func deleteProduct(at indexSet: IndexSet) {
//        products.remove(atOffsets: indexSet)
        // TODO: Firestoreからの削除処理などをここに実装
    }
}
