//
//  Post.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

//Model
import Foundation
import PhotosUI

struct Log: Identifiable {
    let id: UUID = UUID()
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
    var logImage: UIImage?
    var textOffset: CGSize = .zero
    var tagX: CGFloat = 0
    var tagY: CGFloat = 0
}

struct User: Identifiable{
    let id: UUID = UUID()
    let userNo: Int
    var userName: String
    var selfIntroduction: String
    var favoriteCoffee: String
    var favoriteCoffeeImage: UIImage?
    var profileImage: UIImage?
    var probitter: Int
    var proacidity: Int
    var probody: Int
    var proaroma: Int
    var proflavor: String
}
