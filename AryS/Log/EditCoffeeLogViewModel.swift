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
    
    // 💡 切り替えフラグと各種国プロパティ
    var isBlend: Bool = false
    var countryName: String = ""
    var blend: String = ""
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
    var offColor = Color.gray
    var onColor = Color.yellow
    
    init(log: Log) {
        self.shopName = log.shopName
        self.blend = log.blend
         
        // 💡 データの読み込み
        let loadedIsBlend = log.isBlend ?? false
        self.isBlend = loadedIsBlend
         
        // 💡 古いデータなどで isBlend が未設定（nil）かつ、countryName にカンマが含まれている場合の救済処理
        if (log.isBlend == nil || log.isBlend == false) && log.countryName.contains(",") {
            let countries = log.countryName.components(separatedBy: ", ")
            self.isBlend = true
            self.blendCountry1 = countries.indices.contains(0) ? countries[0] : ""
            self.blendCountry2 = countries.indices.contains(1) ? countries[1] : ""
            self.blendCountry3 = countries.indices.contains(2) ? countries[2] : ""
             
            // ブレンド扱いになったのでシングル側は空にする
            self.countryName = ""
            self.farmName = ""
            self.grade = ""
            self.roastLevel = ""
        } else if self.isBlend {
            // 💡 ブレンド投稿の場合：シングルオリジン側の情報は保持しない（空にする）
            self.blendCountry1 = log.blendCountry1 ?? ""
            self.blendCountry2 = log.blendCountry2 ?? ""
            self.blendCountry3 = log.blendCountry3 ?? ""
             
            self.countryName = ""
            self.farmName = ""
            self.grade = ""
            self.roastLevel = ""
        } else {
            // 💡 シングルオリジン投稿の場合：ブレンド側の情報は保持しない（空にする）
            self.countryName = log.countryName
            self.farmName = log.farmName
            self.grade = log.grade
            self.roastLevel = log.roastLevel
             
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
         
        // 💡 ブレンドかシングルオリジンかに応じて、反対側の不要なデータを確実に空文字にして保存する
        let finalCountryName = isBlend ? "" : countryName
        let finalFarmName = isBlend ? "" : farmName
        let finalGrade = isBlend ? "" : grade
        let finalRoastLevel = isBlend ? "" : roastLevel
         
        let finalBlendCountry1 = isBlend ? blendCountry1 : ""
        let finalBlendCountry2 = isBlend ? blendCountry2 : ""
        let finalBlendCountry3 = isBlend ? blendCountry3 : ""
         
        let updatedData: [String: Any] = [
            "shopName": shopName,
            "blend": blend,
            "isBlend": isBlend,
            "countryName": finalCountryName,
            "blendCountry1": finalBlendCountry1,
            "blendCountry2": finalBlendCountry2,
            "blendCountry3": finalBlendCountry3,
            "farmName": finalFarmName,
            "grade": finalGrade,
            "roastLevel": finalRoastLevel,
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
    
    // 💡 編集された最新の入力値を反映した Log オブジェクトを生成するヘルパーメソッド
    func makeUpdatedLog(from original: Log) -> Log {
        var updated = original
        updated.shopName = shopName.isEmpty ? "店舗名未入力" : shopName
        updated.blend = blend
        updated.isBlend = isBlend
        updated.countryName = isBlend ? blendCountry1 : countryName
        updated.blendCountry1 = isBlend ? blendCountry1 : nil
        updated.blendCountry2 = isBlend ? blendCountry2 : nil
        updated.blendCountry3 = isBlend ? blendCountry3 : nil
        updated.farmName = farmName
        updated.grade = grade
        updated.roastLevel = roastLevel
        updated.flavorrating = flavorrating
        updated.memo = memo
        updated.bitternessrating = bitternessrating
        updated.acidityrating = acidityrating
        updated.bodyrating = bodyrating
        updated.sweetnessrating = sweetnessrating
        updated.flavorTags = selectedAroma.isEmpty ? [] : [selectedAroma]
        return updated
    }
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
}
