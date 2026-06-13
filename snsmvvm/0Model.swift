//
//  Post.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import Foundation
import FirebaseFirestore
import UIKit

struct Log: Codable, Identifiable {
    @DocumentID var id: String? = nil
    var user: User
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
    var logImages: [UIImage] = []
    var textOffset: CGSize = .zero
    
    enum CodingKeys: String, CodingKey {
        case id, user, shopName, countryName, farmName, roastLevel
        case aromarating, aromaComment, bitternessrating1, acidityrating1, bodyrating1
        case bitternessrating2, acidityrating2, bodyrating2, createdAt
        case tagX, tagY, imageUrl
    }
    
    // 💡 これを追加：Firestoreから読み込むためのイニシャライザ
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        user = try container.decode(User.self, forKey: .user)
        shopName = try container.decode(String.self, forKey: .shopName)
        countryName = try container.decode(String.self, forKey: .countryName)
        farmName = try container.decode(String.self, forKey: .farmName)
        roastLevel = try container.decode(String.self, forKey: .roastLevel)
        aromarating = try container.decode(Int.self, forKey: .aromarating)
        aromaComment = try container.decode(String.self, forKey: .aromaComment)
        bitternessrating1 = try container.decode(Int.self, forKey: .bitternessrating1)
        acidityrating1 = try container.decode(Int.self, forKey: .acidityrating1)
        bodyrating1 = try container.decode(Int.self, forKey: .bodyrating1)
        bitternessrating2 = try container.decode(Int.self, forKey: .bitternessrating2)
        acidityrating2 = try container.decode(Int.self, forKey: .acidityrating2)
        bodyrating2 = try container.decode(Int.self, forKey: .bodyrating2)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        tagX = try container.decode(CGFloat.self, forKey: .tagX)
        tagY = try container.decode(CGFloat.self, forKey: .tagY)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
    }

    // 💡 これを追加：新規作成時に使うイニシャライザ
    init(user: User, shopName: String, countryName: String, farmName: String, roastLevel: String, aromarating: Int, aromaComment: String, bitternessrating1: Int, acidityrating1: Int, bodyrating1: Int, bitternessrating2: Int, acidityrating2: Int, bodyrating2: Int, createdAt: Date, tagX: CGFloat, tagY: CGFloat) {
        self.user = user
        self.shopName = shopName
        self.countryName = countryName
        self.farmName = farmName
        self.roastLevel = roastLevel
        self.aromarating = aromarating
        self.aromaComment = aromaComment
        self.bitternessrating1 = bitternessrating1
        self.acidityrating1 = acidityrating1
        self.bodyrating1 = bodyrating1
        self.bitternessrating2 = bitternessrating2
        self.acidityrating2 = acidityrating2
        self.bodyrating2 = bodyrating2
        self.createdAt = createdAt
        self.tagX = tagX
        self.tagY = tagY
    }
}

struct User: Codable, Identifiable {
    @DocumentID var id: String? = nil
    let userNo: Int
    var userName: String
    var selfIntroduction: String
    var userAge: Int
    var birthPlace: String
    var favoriteCoffee: String
    var probitter: Int
    var proacidity: Int
    var probody: Int
    var proaroma: Int
    var proflavor: String
    
    // 画像は一時的に保持するだけで、Firestoreには保存しないため除外します
    var profileImage: UIImage? = nil
    var favoriteCoffeeImage: UIImage? = nil
    
    // 💡 これが重要：Codableに対応させるためのキー定義
    enum CodingKeys: String, CodingKey {
        case id, userNo, userName, selfIntroduction, userAge, birthPlace, favoriteCoffee
        case probitter, proacidity, probody, proaroma, proflavor
        // profileImage, favoriteCoffeeImage はここに入れないことで除外される
    }
    
    // User 構造体の init を以下のように修正（引数名を profileImage に合わせる）
    init(userNo: Int, userName: String, selfIntroduction: String, userAge: Int, birthPlace: String, favoriteCoffee: String, profileImage: UIImage? = nil, probitter: Int, proacidity: Int, probody: Int, proaroma: Int, proflavor: String) {
        self.userNo = userNo
        self.userName = userName
        self.selfIntroduction = selfIntroduction
        self.userAge = userAge
        self.birthPlace = birthPlace
        self.favoriteCoffee = favoriteCoffee
        self.profileImage = profileImage // 👈 ここを合わせる
        self.probitter = probitter
        self.proacidity = proacidity
        self.probody = probody
        self.proaroma = proaroma
        self.proflavor = proflavor
    }
    
    // 💡 Firestoreから読み込むためのイニシャライザ（必須）
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userNo = try container.decode(Int.self, forKey: .userNo)
        userName = try container.decode(String.self, forKey: .userName)
        selfIntroduction = try container.decode(String.self, forKey: .selfIntroduction)
        userAge = try container.decode(Int.self, forKey: .userAge)
        birthPlace = try container.decode(String.self, forKey: .birthPlace)
        favoriteCoffee = try container.decode(String.self, forKey: .favoriteCoffee)
        probitter = try container.decode(Int.self, forKey: .probitter)
        proacidity = try container.decode(Int.self, forKey: .proacidity)
        probody = try container.decode(Int.self, forKey: .probody)
        proaroma = try container.decode(Int.self, forKey: .proaroma)
        proflavor = try container.decode(String.self, forKey: .proflavor)
    }
}

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
