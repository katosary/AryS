//
//  Post.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import Foundation
import FirebaseFirestore
import UIKit

struct Log: Codable, Identifiable, Equatable {
    @DocumentID var id: String? = nil
    
   
    var userId: String = ""
    var shopName: String = ""
    var blend: String = ""
    var countryName: String = ""
    var farmName: String = ""
    var grade: String = ""
    var roastLevel: String = ""
    
    var flavorrating: Int = 0
    var memo: String = ""
    var bitternessrating: Int = 0
    var acidityrating: Int = 0
    var bodyrating: Int = 0
    var sweetnessrating: Int = 0
    
    var aromarating: Int? = 0
    var aromaComment: String? = nil
    var aromaTags: [String]? = []
    
    var flavorTags: [String]? = []
    var createdAt: Date = Date()
    
    var tagX: CGFloat = 0.0
    var tagY: CGFloat = 0.0
    
    var imageUrl: String? = nil
    var previewImage: UIImage? = nil

    var likesCount: Int = 0
    var likedUserIds: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, userId, shopName, blend, countryName, farmName, grade, roastLevel
        case flavorrating, memo, aromarating, aromaComment
        case bitternessrating, acidityrating, bodyrating, sweetnessrating
        case flavorTags, aromaTags
        case createdAt, tagX, tagY, imageUrl
        case likesCount, likedUserIds
    }

    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.id == rhs.id
    }
}


struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var userNo: Int = 1
    var userName: String = ""
    var email: String = ""
    var selfIntroduction: String = ""
    var userAge: Int = 0
    var prefecture: String = ""
    var favoriteCoffee: String = ""
    var probitter: Int = 0
    var proacidity: Int = 0
    var probody: Int = 0
    var proaroma: Int = 0
    var prosweetness: Int = 0
    var proflavor: Int = 0
    var flavorTags: [String] = []
    var dripper: String = ""
    var paperFilter: String = ""
    var kettle: String = ""
    var server: String = ""
    var scale: String = ""
    var mill: String = ""
    var grinder: String = ""
    var espressoMachine: String = ""
    var frenchPress: String = ""
    var profileImageUrl: String? = nil
    var favoriteToolImageUrl: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case userNo
        case userName
        case email
        case selfIntroduction
        case userAge
        case prefecture
        case favoriteCoffee
        case probitter
        case proacidity
        case probody
        case proaroma
        case prosweetness
        case proflavor
        case flavorTags
        case dripper
        case paperFilter
        case kettle
        case server
        case scale
        case mill
        case grinder
        case espressoMachine
        case frenchPress
        case profileImageUrl
        case favoriteToolImageUrl
    }
}

struct Member: Codable {
    let id: String
    let email: String
    let createdAt: Date
}
