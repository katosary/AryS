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
    var farmName: String = ""
    var countryName: String = ""
    var roastLevel: String = ""
    
    var aromarating: Int = 0
    var memo: String = "" // 💡 aromaComment から memo に変更・統一
    
    var bitternessrating: Int = 0
    var acidityrating: Int = 0
    var bodyrating: Int = 0
    
    // 💡 フレーバー選択用のプロパティと選択肢を追加
    var selectedAromas: [String] = []
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
    
    // ピッカー表示用のフラグ
    var isShowingCountryPicker: Bool = false
    var isShowingRoastPicker: Bool = false
    
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    
    // 💡 初期化時に既存のLogデータをプロパティに埋め込む
    init(log: Log) {
        self.shopName = log.shopName
        self.farmName = log.farmName
        self.countryName = log.countryName
        self.roastLevel = log.roastLevel
        self.aromarating = log.aromarating
        self.memo = log.aromaComment // LogのaromaCommentをmemoに代入
        self.bitternessrating = log.bitternessrating
        self.acidityrating = log.acidityrating
        self.bodyrating = log.bodyrating
        self.selectedAromas = log.aromaTags ?? [] // 💡 nilの場合は空の配列を代入する
    }
    
    func updateLog(targetPost: Log, completion: @escaping (Bool) -> Void) {
        guard let postId = targetPost.id else {
            print("エラー: 投稿のIDが見つかりません")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        
        let updatedData: [String: Any] = [
            "shopName": shopName,
            "farmName": farmName,
            "countryName": countryName,
            "roastLevel": roastLevel,
            "aromarating": aromarating,
            "aromaComment": memo, // 💡 Firestoreには aromaComment として保存
            "bitternessrating": bitternessrating,
            "acidityrating": acidityrating,
            "bodyrating": bodyrating,
            "aromaTags": selectedAromas // 💡 選択されたタグも保存
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
