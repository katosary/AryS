//
//  4.MatchingViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/25.
//

import Foundation
import Observation
import FirebaseCore       // Firebase自体の初期化（configure）に必要
import FirebaseFirestore  // Firestoreのデータベース操作に必要

@Observable
@MainActor
class MatchingViewModel {
    private var db: Firestore
    // モデル名を CoffeeProfile に変更
    var discoveredProfiles: [CoffeeProfile] = []
    var isLoading = false
    
    init() {
        self.db = Firestore.firestore()
    }
    
    func fetchRecommendedProfiles() async {
        isLoading = true
        
        // モダンな待ち時間の書き方
        try? await Task.sleep(for: .seconds(1))
        
        // 変更したモデル名で初期化
        self.discoveredProfiles = [
            CoffeeProfile(name: "田中 健太", coffeeStyle: "深煎り派", bio: "週末は自家焙煎しています。"),
            CoffeeProfile(name: "佐藤 美咲", coffeeStyle: "カフェラテ好き", bio: "可愛いラテアートのお店を探しています。"),
            CoffeeProfile(name: "鈴木 亮", coffeeStyle: "浅煎り・フルーティー", bio: "酸味のあるエチオピアが好きです。")
        ]
        
        isLoading = false
    }
}

// Sendable を追加
struct CoffeeProfile: Identifiable, Sendable {
    let id: UUID
    let name: String
    let coffeeStyle: String
    let bio: String
    
    init(id: UUID = UUID(), name: String, coffeeStyle: String, bio: String) {
        self.id = id
        self.name = name
        self.coffeeStyle = coffeeStyle
        self.bio = bio
    }
}
