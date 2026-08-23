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
    var blend: String = ""
    var farmName: String = ""
    var grade: String = ""
    var countryName: String = ""
    var roastLevel: String = ""
    
    var aromarating: Int = 0
    var memo: String = ""
    
    var bitternessrating: Int = 0
    var acidityrating: Int = 0
    var bodyrating: Int = 0
    var sweetnessrating: Int = 0
    
    // 💡 フレーバーを1つだけ選択する仕様
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
    
    var isShowingCountryPicker: Bool = false
    var isShowingRoastPicker: Bool = false
    
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    
    init(log: Log) {
        self.shopName = log.shopName
        self.blend = log.blend
        self.farmName = log.farmName
        self.grade = log.grade
        self.countryName = log.countryName
        self.roastLevel = log.roastLevel
        self.aromarating = log.flavorrating
        self.memo = log.memo
        self.bitternessrating = log.bitternessrating
        self.acidityrating = log.acidityrating
        self.bodyrating = log.bodyrating
        self.sweetnessrating = log.sweetnessrating
        
        // 既存のflavorTagsの最初の要素を単一選択用としてセット
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
        
        // 保存時は選択された1つのフレーバーを配列（1要素）にして保存
        let tagsToSave = selectedAroma.isEmpty ? [] : [selectedAroma]
        
        let updatedData: [String: Any] = [
            "shopName": shopName,
            "blend": blend,
            "farmName": farmName,
            "grade": grade,
            "countryName": countryName,
            "roastLevel": roastLevel,
            "flavorrating": aromarating, // 💡 ここを "flavorrating" に合わせる
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
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
}
