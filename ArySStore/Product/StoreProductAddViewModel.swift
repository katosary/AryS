//
//  StoreProductAddViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import Foundation

@Observable
class StoreProductAddViewModel {
    var productName = ""
    var productPrice = ""
    var productDescription = ""

    func addProduct(completion: () -> Void) {
        // TODO: Firestoreへの登録処理などをここに実装
        completion()
    }
}
