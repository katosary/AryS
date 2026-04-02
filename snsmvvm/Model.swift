//
//  Post.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

//Model
import Foundation

struct Post: Identifiable {
    let id: UUID = UUID()
    var user: User
    var coffeeName: String
    var content: String
    var rating: Int
    var createdAt: Date
}

struct User: Identifiable{
    let id: UUID = UUID()
    let userNo: Int
    var userName: String
    var favoriteCoffee: String
}
