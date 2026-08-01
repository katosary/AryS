//
//  Post.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import Foundation
import FirebaseFirestore
import UIKit

// Log.swift
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
    var createdAt: Date
    var tagX: CGFloat
    var tagY: CGFloat
    var imageUrl: String?
    var previewImage: UIImage? = nil
    
    // Firestoreに保存するキーをプロパティと一致させる
    enum CodingKeys: String, CodingKey {
        case id, userId, shopName, countryName, farmName, roastLevel
        case aromarating, aromaComment, bitternessrating, acidityrating, bodyrating
        case createdAt, tagX, tagY, imageUrl
    }
    
    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.id == rhs.id
    }
}

struct User: Codable, Identifiable {
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
    
    // 💡 すべて 「?」 をつけるか、初期値を設定する
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
    var favoriteCoffeeImageUrl: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, userNo, userName, email, selfIntroduction, userAge, prefecture, favoriteCoffee
        case probitter, proacidity, probody, proaroma, proflavor
        case dripper, paperFilter, kettle, server, scale, mill, grinder, espressoMachine, frenchPress
        case profileImageUrl, favoriteCoffeeImageUrl
    }
}

struct Member: Codable {
    let id: String
    let email: String
    let createdAt: Date
    // 必要に応じて displayName, iconURL などを追加
}
