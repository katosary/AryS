//
//  Post.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import Foundation
import FirebaseFirestore
import UIKit
import SwiftUI
import FirebaseFirestore


struct Log: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    
    var userId: String = ""
    var shopName: String = ""
    var blend: String? = nil         // オプショナルに変更
    var countryName: String = "" // シングルオリジン用
    
    var isBlend: Bool? = false
    var blendCountry1: String? = ""
    var blendCountry2: String? = ""
    var blendCountry3: String? = ""
    
    var brand: String? = nil         // オプショナルに変更
    var farmName: String = ""
    var grade: String = ""
    var roastLevel: String = ""
    
    var flavorrating: Int = 0
    var memo: String = ""
    var bitternessrating: Int = 0
    var acidityrating: Int = 0
    var bodyrating: Int = 0
    var sweetnessrating: Int = 0
    
    var flavorTags: [String]? = []
    var createdAt: Date = Date()
    
    var tagX: CGFloat = 0.0
    var tagY: CGFloat = 0.0
    
    var imageUrl: String? = nil
    var previewImage: UIImage? = nil

    var likesCount: Int = 0
    var likedUserIds: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, userId, shopName, blend, countryName
        case isBlend, blendCountry1, blendCountry2, blendCountry3
        case brand, farmName, grade, roastLevel
        case flavorrating, memo
        case bitternessrating, acidityrating, bodyrating, sweetnessrating
        case flavorTags
        case createdAt, tagX, tagY, imageUrl
        case likesCount, likedUserIds
    }

    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.id == rhs.id
    }
}

struct User: Identifiable, Codable, Hashable { 
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
        case id, userNo, userName, email, selfIntroduction, userAge, prefecture, favoriteCoffee
        case probitter, proacidity, probody, proaroma, prosweetness, proflavor
        case flavorTags, dripper, paperFilter, kettle, server, scale, mill, grinder
        case espressoMachine, frenchPress, profileImageUrl, favoriteToolImageUrl
    }
    
    // ⬅️ 2. Hashable & Equatable のための実装を追加
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
         
        func decodeInt(forKey key: CodingKeys, defaultValue: Int) -> Int {
            if let intVal = try? container.decodeIfPresent(Int.self, forKey: key) {
                return intVal
            } else if let strVal = try? container.decodeIfPresent(String.self, forKey: key), let converted = Int(strVal) {
                return converted
            }
            return defaultValue
        }
         
        self.userNo = decodeInt(forKey: .userNo, defaultValue: 1)
        self.userAge = decodeInt(forKey: .userAge, defaultValue: 0)
         
        self.userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.selfIntroduction = try container.decodeIfPresent(String.self, forKey: .selfIntroduction) ?? ""
        self.prefecture = try container.decodeIfPresent(String.self, forKey: .prefecture) ?? ""
        self.favoriteCoffee = try container.decodeIfPresent(String.self, forKey: .favoriteCoffee) ?? ""
         
        self.probitter = decodeInt(forKey: .probitter, defaultValue: 0)
        self.proacidity = decodeInt(forKey: .proacidity, defaultValue: 0)
        self.probody = decodeInt(forKey: .probody, defaultValue: 0)
        self.proaroma = decodeInt(forKey: .proaroma, defaultValue: 0)
        self.prosweetness = decodeInt(forKey: .prosweetness, defaultValue: 0)
        self.proflavor = decodeInt(forKey: .proflavor, defaultValue: 0)
         
        self.flavorTags = try container.decodeIfPresent([String].self, forKey: .flavorTags) ?? []
        self.dripper = try container.decodeIfPresent(String.self, forKey: .dripper) ?? ""
        self.paperFilter = try container.decodeIfPresent(String.self, forKey: .paperFilter) ?? ""
        self.kettle = try container.decodeIfPresent(String.self, forKey: .kettle) ?? ""
        self.server = try container.decodeIfPresent(String.self, forKey: .server) ?? ""
        self.scale = try container.decodeIfPresent(String.self, forKey: .scale) ?? ""
        self.mill = try container.decodeIfPresent(String.self, forKey: .mill) ?? ""
        self.grinder = try container.decodeIfPresent(String.self, forKey: .grinder) ?? ""
        self.espressoMachine = try container.decodeIfPresent(String.self, forKey: .espressoMachine) ?? ""
        self.frenchPress = try container.decodeIfPresent(String.self, forKey: .frenchPress) ?? ""
        self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        self.favoriteToolImageUrl = try container.decodeIfPresent(String.self, forKey: .favoriteToolImageUrl)
    }
    
    init(
        id: String? = nil,
        userNo: Int = 1,
        userName: String = "",
        email: String = "",
        selfIntroduction: String = "",
        userAge: Int = 0,
        prefecture: String = "",
        favoriteCoffee: String = "",
        probitter: Int = 0,
        proacidity: Int = 0,
        probody: Int = 0,
        proaroma: Int = 0,
        prosweetness: Int = 0,
        proflavor: Int = 0,
        flavorTags: [String] = [],
        dripper: String = "",
        paperFilter: String = "", // デフォルト値を追加しておくと便利です
        kettle: String = "",
        server: String = "",
        scale: String = "",
        mill: String = "",
        grinder: String = "",
        espressoMachine: String = "",
        frenchPress: String = "",
        profileImageUrl: String? = nil,
        favoriteToolImageUrl: String? = nil
    ) {
        self.id = id
        self.userNo = userNo
        self.userName = userName
        self.email = email
        self.selfIntroduction = selfIntroduction
        self.userAge = userAge
        self.prefecture = prefecture
        self.favoriteCoffee = favoriteCoffee
        self.probitter = probitter
        self.proacidity = proacidity
        self.probody = probody
        self.proaroma = proaroma
        self.prosweetness = prosweetness
        self.proflavor = proflavor
        self.flavorTags = flavorTags
        self.dripper = dripper
        self.paperFilter = paperFilter
        self.kettle = kettle
        self.server = server
        self.scale = scale
        self.mill = mill
        self.grinder = grinder
        self.espressoMachine = espressoMachine
        self.frenchPress = frenchPress
        self.profileImageUrl = profileImageUrl
        self.favoriteToolImageUrl = favoriteToolImageUrl
    }
}

struct Member: Codable {
    let id: String
    let email: String
    let createdAt: Date
}
