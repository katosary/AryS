//
//  EditCoffeeLogViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/04.
//

import SwiftUI

@Observable
class EditCoffeeLogViewModel {
    var shopName: String = ""
    var farmName: String = ""
    var countryName: String = ""
    var roastLevel: String = ""
    
    var aromarating: Int = 0
    var aromaComment: String = ""
    
    var bitternessrating: Int = 0
    var acidityrating: Int = 0
    var bodyrating: Int = 0
    
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
        self.aromaComment = log.aromaComment
        self.bitternessrating = log.bitternessrating
        self.acidityrating = log.acidityrating
        self.bodyrating = log.bodyrating
    }
    
    func updateLog(targetPost: Log, completion: @escaping (Bool) -> Void) {
        // TODO: Firebaseなどのバックエンドやデータソースへの更新処理をここに記述します
        // 例として成功したと仮定してcompletionを呼ぶ形にしています
        completion(true)
    }
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
}
