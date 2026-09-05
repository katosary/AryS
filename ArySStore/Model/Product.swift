//
//  Product.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import Foundation

struct Product: Identifiable {
    let id = UUID()
    var name: String // 商品名
    var price: String // 価格
    var roastLevel: String // 焙煎度合いなど
}
