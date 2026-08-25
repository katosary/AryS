//
//  CoffeeRecordViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/19.
//

import Observation
import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

@Observable
class CoffeeRecordViewModel {
    // MARK: - フォーム入力データ
    var shopName: String = ""
    
    // 💡 シングルオリジン / ブレンドの切り替え (false: シングルオリジン, true: ブレンド)
    var isBlend: Bool = false
    
    // シングルオリジン用
    var countryName: String = ""
    var blend: String = "" // （※既存のコード構造に合わせてブレンド用名称として使用）
    var farmName: String = ""
    var grade: String = ""
    
    // ブレンド用（3つまで選択可能）
    var blendCountry1: String = ""
    var blendCountry2: String = ""
    var blendCountry3: String = ""
    
    var roastLevel: String = ""
     
    // 評価（5段階評価）
    var flavorrating: Int = 0
    var memo: String = ""
    var bitternessrating: Int = 0
    var acidityrating: Int = 0
    var bodyrating: Int = 0
    var sweetnessrating: Int = 0
     
    // 香りのタグ選択用プロパティ（単一選択）
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
     
    // 写真関連
    var selectedItems: [PhotosPickerItem] = [] {
        didSet { Task { await loadImages() } }
    }
    var logImages: [UIImage] = []
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
     
    // ピッカーの状態管理
    var isShowingCountryPicker: Bool = false
    var activeCountryTarget: CountryTarget = .single // 💡 どの国のピッカーを開いているかを識別
    var isShowingRoastPicker: Bool = false
     
    enum CountryTarget {
        case single, blend1, blend2, blend3
    }
     
    // 定数・設定
    let maxRating = 5
    let offColor = Color.gray
    let onColor = Color.yellow
     
    // MARK: - 初期化
    private let db = Firestore.firestore()
     
    @MainActor
    private func loadImages() async {
        logImages = []
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                logImages.append(uiImage)
            }
        }
    }
     
    // MARK: - 投稿・保存処理
    func uploadAndSaveLog(currentUser: FirebaseAuth.User, completion: @escaping (Bool) -> Void) {
        guard let image = logImages.first else {
            saveLogToFirestore(imageUrl: nil, completion: completion)
            return
        }
          
        guard let resizedBaseImage = image.resize(toMaxLongSide: 1080) else {
            completion(false); return
        }
          
        guard let cropped = cropImage(image: resizedBaseImage, scale: scale, offset: offset, containerSize: CGSize(width: 300, height: 400)),
              let data = cropped.jpegData(compressionQuality: 0.7) else {
            completion(false); return
        }
          
        let filename = NSUUID().uuidString + ".jpg"
        let ref = Storage.storage().reference().child("post_images").child(filename)
          
        ref.putData(data, metadata: nil) { _, error in
            if error != nil { completion(false); return }
            ref.downloadURL { url, _ in
                self.saveLogToFirestore(imageUrl: url?.absoluteString, completion: completion)
            }
        }
    }
     
    private func saveLogToFirestore(imageUrl: String?, completion: @escaping (Bool) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(false); return
            }
            
            let newLog = Log(
                userId: uid,
                shopName: shopName,
                blend: blend,
                countryName: isBlend ? "" : countryName, // 💡 シングル時のみ保持
                isBlend: isBlend,                        // 💡 追加
                blendCountry1: isBlend ? blendCountry1 : "", // 💡 ブレンド時のみ保持
                blendCountry2: isBlend ? blendCountry2 : "",
                blendCountry3: isBlend ? blendCountry3 : "",
                farmName: isBlend ? "" : farmName,
                grade: isBlend ? "" : grade,
                roastLevel: roastLevel,
                flavorrating: flavorrating,
                memo: memo,
                bitternessrating: bitternessrating,
                acidityrating: acidityrating,
                bodyrating: bodyrating,
                sweetnessrating: sweetnessrating,
                flavorTags: selectedAroma.isEmpty ? [] : [selectedAroma],
                createdAt: Date(),
                tagX: 0,
                tagY: 0,
                imageUrl: imageUrl
            )
             
            do {
                _ = try db.collection("posts").document().setData(from: newLog) // あるいは addDocument(from:)
                clearFormFields()
                completion(true)
            } catch {
                print("Firestore保存失敗: \(error.localizedDescription)")
                completion(false)
            }
        }
     
    func resetForm() {
        clearFormFields()
    }
     
    private func clearFormFields() {
        shopName = ""
        isBlend = false
        blend = ""
        countryName = ""
        farmName = ""
        grade = ""
        blendCountry1 = ""
        blendCountry2 = ""
        blendCountry3 = ""
        roastLevel = ""
        flavorrating = 0
        memo = ""
        bitternessrating = 0
        acidityrating = 0
        bodyrating = 0
        sweetnessrating = 0
        logImages = []
        selectedAroma = ""
        selectedItems = []
        scale = 1.0
        offset = .zero
    }
     
    private func cropImage(image: UIImage, scale: CGFloat, offset: CGSize, containerSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: containerSize)
        return renderer.image { _ in
            let aspectRatio = image.size.width / image.size.height
            let targetWidth = (aspectRatio > containerSize.width/containerSize.height) ? (containerSize.height * aspectRatio * scale) : (containerSize.width * scale)
            let targetHeight = (aspectRatio > containerSize.width/containerSize.height) ? (containerSize.height * scale) : (containerSize.width / aspectRatio * scale)
            let x = (containerSize.width - targetWidth) / 2 + offset.width
            let y = (containerSize.height - targetHeight) / 2 + offset.height
            image.draw(in: CGRect(x: x, y: y, width: targetWidth, height: targetHeight))
        }
    }
}
