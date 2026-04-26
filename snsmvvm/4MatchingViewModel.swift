//
//  4.MatchingViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/25.
//

import Foundation
import Observation // iOS 17+ の場合

@Observable // @StateObjectを使う場合は class & ObservableObject
class MatchingViewModel {
    var discoveredProfiles: [UserProfile] = []
    var isLoading = false
    
    // 他人のプロフィールを取得する関数
    func fetchRecommendedProfiles() async {
        isLoading = true
        
        // --- ここで本来はAPI通信やFirebaseの取得処理を行う ---
        // 例: FirebaseFirestore.collection("users").where("uid", "!=", currentUid).get()
        
        // 擬似的な待ち時間
        //try? await Task.sleep(forNanoseconds: 1_000_000_000)
        
        // テストデータ
        self.discoveredProfiles = [
            UserProfile(name: "田中 健太", coffeeStyle: "深煎り派", bio: "週末は自家焙煎しています。"),
            UserProfile(name: "佐藤 美咲", coffeeStyle: "カフェラテ好き", bio: "可愛いラテアートのお店を探しています。"),
            UserProfile(name: "鈴木 亮", coffeeStyle: "浅煎り・フルーティー", bio: "酸味のあるエチオピアが好きです。")
        ]
        
        isLoading = false
    }
}

// ユーザー情報のモデル
struct UserProfile: Identifiable {
    let id = UUID()
    let name: String
    let coffeeStyle: String
    let bio: String
    // let profileImageUrl: String // 実際にはURLで管理
}
