//
//  StoreProductFormViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI
import Observation

@Observable
class StoreProductFormViewModel {
    var product: Product
    
    var productName: String
    var priceText: String
    var greenBeanText: String
    var packagingText: String
    var shippingText: String
    var descriptionText: String
    
    var sampleImages: [String] = ["photo1", "photo2", "photo3"]
    var currentIndex = 0
    var isShowingImagePicker = false
    
    init(product: Product) {
        self.product = product
        self.productName = product.name
        self.priceText = product.price.replacingOccurrences(of: "円", with: "")
        self.greenBeanText = "300"
        self.packagingText = "50"
        self.shippingText = "200"
        self.descriptionText = "ここに商品の詳しい説明やこだわりが入ります。"
    }
    
    func calculateCreditFee() -> Int {
        let price = Double(priceText) ?? 0.0
        return Int(price * 0.035)
    }
    
    func calculateProfit() -> Int {
        let price = Int(priceText) ?? 0
        let greenBean = Int(greenBeanText) ?? 0
        let packaging = Int(packagingText) ?? 0
        let shipping = Int(shippingText) ?? 0
        let creditFee = calculateCreditFee()
        
        return price - (greenBean + packaging + shipping + creditFee)
    }
}
