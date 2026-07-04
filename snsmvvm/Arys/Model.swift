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
    var bitternessrating1: Int
    var acidityrating1: Int
    var bodyrating1: Int
    var bitternessrating2: Int
    var acidityrating2: Int
    var bodyrating2: Int
    var createdAt: Date
    var tagX: CGFloat
    var tagY: CGFloat
    var imageUrl: String?
    var previewImage: UIImage?
    
    // 💡 Firestoreに保存しないものは CodingKeys に書かない！
    enum CodingKeys: String, CodingKey {
        case id, userId, shopName, countryName, farmName, roastLevel
        case aromarating, aromaComment, bitternessrating1, acidityrating1, bodyrating1
        case bitternessrating2, acidityrating2, bodyrating2, createdAt
        case tagX, tagY, imageUrl
    }
    
    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.id == rhs.id
    }
}

struct User: Codable, Identifiable {
    @DocumentID var id: String? = nil
    
    // 基本データ
    var userNo: Int
    var userName: String
    var selfIntroduction: String
    var userAge: Int
    var birthPlace: String
    var favoriteCoffee: String
    
    // プロフィールデータ（数値系）
    var probitter: Int
    var proacidity: Int
    var probody: Int
    var proaroma: Int
    var proflavor: String
    
    // 💡 Firebase Storage に保存した画像のURLを文字列で保持
    var profileImageUrl: String? = nil
    var favoriteCoffeeImageUrl: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, userNo, userName, selfIntroduction, userAge, birthPlace, favoriteCoffee
        case probitter, proacidity, probody, proaroma, proflavor
        case profileImageUrl, favoriteCoffeeImageUrl
    }
}

// 💡 補足：もしコード内で一時的に UIImage を保持したい場合は、
// User モデル自体を汚さずに、View の ViewModel 側で保持する方が設計が綺麗です。
struct Tool: Identifiable{
    let id: UUID = UUID()
    var dripper: String
    var paperFilter: String
    var kettle: String
    var server: String
    var scale: String
    var mill: String
    var grinder: String
    var espressoMachine: String
    var frenchPress: String
    var toolImage: UIImage?
}


struct Member: Codable {
    let id: String
    let email: String
    let createdAt: Date
    // 必要に応じて displayName, iconURL などを追加
}
