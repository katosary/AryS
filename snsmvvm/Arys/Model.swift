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
    var userId: String
    var shopName: String
    var countryName: String
    var farmName: String
    var roastLevel: String
    var aromarating: Int
    var aromaComment: String
    var bitternessrating: Int
    var acidityrating: Int
    var bodyrating: Int
    var aromaTags: [String]? = [] // 💡 オプショナルに変更
    var createdAt: Date
    var tagX: CGFloat
    var tagY: CGFloat
    var imageUrl: String?
    var previewImage: UIImage? = nil

    var likesCount: Int = 0
    var likedUserIds: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case id, userId, shopName, countryName, farmName, roastLevel
        case aromarating, aromaComment, bitternessrating, acidityrating, bodyrating
        case aromaTags
        case createdAt, tagX, tagY, imageUrl
        case likesCount, likedUserIds
    }
    
    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.id == rhs.id
    }
}

struct User: Codable, Identifiable, Equatable {
    @DocumentID var id: String? = nil
    
    // 基本データ
    var userNo: Int?
    var userName: String
    var email: String?
    var selfIntroduction: String
    var userAge: Int
    var prefecture: String
    var favoriteCoffee: String
    
    // プロフィールデータ（数値系）
    var probitter: Int
    var proacidity: Int
    var probody: Int
    var proaroma: Int
    var proflavor: String
    var proaromas: [String]? = [] // 💡 オプショナルに変更
    
    var dripper: String? = ""
    var paperFilter: String? = ""
    var kettle: String? = ""
    var server: String? = ""
    var scale: String? = ""
    var mill: String? = ""
    var grinder: String? = ""
    var espressoMachine: String? = ""
    var frenchPress: String? = ""
    
    // 画像URL
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
        case probitter, proacidity, probody, proaroma, proflavor, proaromas
        case dripper, paperFilter, kettle, server, scale, mill, grinder, espressoMachine, frenchPress
        case profileImageUrl
        case favoriteToolImageUrl
    }
}

struct Member: Codable {
    let id: String
    let email: String
    let createdAt: Date
}
