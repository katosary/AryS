//
//  Product.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import Foundation
import FirebaseFirestore

struct Product: Codable, Identifiable {
    @DocumentID var id: String?
    var storeId: String
    var storeName: String
    var productName: String
    var isBlend: Bool
    var countryName: String
    var farmName: String?
    var grade: String?
    var roastLevel: String
    var price: Int
    var greenBeanCost: Int
    var packagingCost: Int
    var shippingCost: Int
    var description: String
    var imageUrl: String
    @ServerTimestamp var createdAt: Timestamp?
}
