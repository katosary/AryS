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
                "aromaComment": aromaComment,
                "bitternessrating": bitternessrating,
                "acidityrating": acidityrating,
                "bodyrating": bodyrating
            ]
            
            // 💡 "logs" をアプリの実際の投稿コレクション名（例: "posts"）に変更する
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
