//
//  EditCoffeeLogViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/04.
//

import SwiftUI
import FirebaseFirestore

@Observable
class EditCoffeeLogViewModel {
    var shopName: String = ""
    
    // 切り替えフラグと各種プロパティ
    var isBlend: Bool = false
    var countryName: String = ""
    var blend: String = ""          // ブレンド名用
    var brand: String = ""          // 銘柄名用（シングルオリジン）
    
    var blendCountry1: String = ""
    var blendCountry2: String = ""
    var blendCountry3: String = ""
     
    var farmName: String = ""
    var grade: String = ""
    var roastLevel: String = ""
     
    var activeCountryTarget: CountryTarget = .single
    var isShowingCountryPicker: Bool = false
    var isShowingRoastPicker: Bool = false
     
    enum CountryTarget {
        case single, blend1, blend2, blend3
    }
     
    var flavorrating: Int = 0
    var memo: String = ""
    var bitternessrating: Int = 0
    var acidityrating: Int = 0
    var bodyrating: Int = 0
    var sweetnessrating: Int = 0
     
    var selectedAroma: String = ""
    let flavorOptions = [
        "フルーティー (みずみずしい果実感)",
        "シトラス (爽やかな柑橘系)",
        "ベリー (甘酸っぱい果実系)",
        "チョコレート (コクのある甘み)",
        "キャラメル (香ばしい甘さ)",
        "ナッツ (香ばしいナッツ感)",
        "黒糖 (まろやかなコク・甘み)",
        "フローラル (華やかな香り)",
        "アーシー (土や大地を思わせる風味)",
        "ハーブ (爽やかな植物感)",
        "スパイス (スパイシーなアクセント)"
    ]
     
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
     
    init(log: Log) {
        self.shopName = log.shopName
         
        let loadedIsBlend = log.isBlend ?? false
        self.isBlend = loadedIsBlend
         
        if self.isBlend {
            self.blend = log.blend ?? "" // ブレンド名
            self.blendCountry1 = log.blendCountry1 ?? ""
            self.blendCountry2 = log.blendCountry2 ?? ""
            self.blendCountry3 = log.blendCountry3 ?? ""
            
            self.countryName = ""
            self.brand = ""
            self.farmName = ""
            self.grade = ""
            self.roastLevel = ""
        } else {
            self.countryName = log.countryName
            self.brand = log.brand ?? "" // 銘柄名
            self.farmName = log.farmName
            self.grade = log.grade
            self.roastLevel = log.roastLevel
            
            self.blend = ""
            self.blendCountry1 = ""
            self.blendCountry2 = ""
            self.blendCountry3 = ""
        }
         
        self.flavorrating = log.flavorrating
        self.memo = log.memo
        self.bitternessrating = log.bitternessrating
        self.acidityrating = log.acidityrating
        self.bodyrating = log.bodyrating
        self.sweetnessrating = log.sweetnessrating
         
        if let firstTag = log.flavorTags?.first {
            self.selectedAroma = firstTag
        }
    }
     
    func updateLog(targetPost: Log, completion: @escaping (Bool) -> Void) {
        guard let postId = targetPost.id else {
            print("エラー: 投稿のIDが見つかりません")
            completion(false)
            return
        }
         
        let db = Firestore.firestore()
        let tagsToSave = selectedAroma.isEmpty ? [] : [selectedAroma]
         
        let updatedData: [String: Any] = [
            "shopName": shopName,
            "isBlend": isBlend,
            "blend": isBlend ? blend : "",
            "brand": isBlend ? "" : brand, // シングルオリジンの時はbrandを保存
            "countryName": isBlend ? "" : countryName,
            "blendCountry1": isBlend ? blendCountry1 : "",
            "blendCountry2": isBlend ? blendCountry2 : "",
            "blendCountry3": isBlend ? blendCountry3 : "",
            "farmName": isBlend ? "" : farmName,
            "grade": isBlend ? "" : grade,
            "roastLevel": isBlend ? "" : roastLevel,
            "flavorrating": flavorrating,
            "memo": memo,
            "bitternessrating": bitternessrating,
            "acidityrating": acidityrating,
            "bodyrating": bodyrating,
            "sweetnessrating": sweetnessrating,
            "flavorTags": tagsToSave
        ]
         
        db.collection("posts").document(postId).updateData(updatedData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("投稿の更新に失敗しました: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("投稿の更新に成功しました")
                    completion(true)
                }
            }
        }
    }
     
    func makeUpdatedLog(from original: Log) -> Log {
            var updated = original
            updated.shopName = shopName.isEmpty ? "店舗名未入力" : shopName
            updated.isBlend = isBlend
            
            // --- ブレンド or シングルオリジン による分岐 ---
            updated.blend = isBlend ? blend : nil
            updated.brand = isBlend ? nil : brand
            
            
            updated.countryName = isBlend ? "" : countryName
            
            updated.blendCountry1 = isBlend ? blendCountry1 : nil
            updated.blendCountry2 = isBlend ? blendCountry2 : nil
            updated.blendCountry3 = isBlend ? blendCountry3 : nil
            
            
            updated.farmName = isBlend ? "" : farmName
            updated.grade = isBlend ? "" : grade
            updated.roastLevel = isBlend ? "" : roastLevel
        
            updated.flavorrating = flavorrating
            updated.memo = memo
            updated.bitternessrating = bitternessrating
            updated.acidityrating = acidityrating
            updated.bodyrating = bodyrating
            updated.sweetnessrating = sweetnessrating
            updated.flavorTags = selectedAroma.isEmpty ? [] : [selectedAroma]
            
            return updated
        }
}
