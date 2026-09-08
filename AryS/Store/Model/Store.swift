//
//  Store.swift
//  ArySStore
//
//  Created by katoso on 2026/09/02.
//

import Foundation
import FirebaseFirestore

struct Store: Identifiable, Codable {
    @DocumentID var id: String?
    var storeName: String
    var postalCode: String
    var prefecture: String
    var city: String
    var streetNumber: String
    var buildingName: String
    var phoneNumber: String
    var email: String
    var storeImageURL: String?
        
        // 焙煎士情報
        var roasterName: String
        var roastingExperience: String
        var roasterBio: String        
        var roastingMachine: String  
        var roasterImageURL: String?
    
    // アンケート項目
    var businessModel: String
    var estimatedRevenue: String
    var desiredFeatures: String
    var futureExpectations: String
    
    var createdAt: Date?
    
    var fullAddress: String {
        return "\(prefecture)\(city)\(streetNumber) \(buildingName)"
    }
}
