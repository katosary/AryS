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
    var blend: String = ""
    var farmName: String = ""
    var grade: String = ""
    var countryName: String = ""
    var roastLevel: String = ""
     
    // 評価（5段階評価）
    var aromarating: Int = 0
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
    var isShowingRoastPicker: Bool = false
     
    // 定数・設定
    let maxRating = 5
    let offColor = Color.gray
    let onColor = Color.yellow
     
    // MARK: - 初期化
    private let db = Firestore.firestore()
     
    // MARK: - UIヘルパー
    func image(for number: Int, rating: Int) -> Image {
        number > rating ? Image(systemName: "star") : Image(systemName: "star.fill")
    }
     
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
            countryName: countryName,
            farmName: farmName,
            grade: grade,
            roastLevel: roastLevel,
            flavorrating: aromarating,
            memo: memo,
            bitternessrating: bitternessrating,
            acidityrating: acidityrating,
            bodyrating: bodyrating,
            sweetnessrating: sweetnessrating, // 💡 修正: 甘味の評価を反映
            flavorTags: selectedAroma.isEmpty ? [] : [selectedAroma],
            createdAt: Date(),
            tagX: 0,
            tagY: 0,
            imageUrl: imageUrl
        )
          
        do {
            _ = try db.collection("posts").addDocument(from: newLog)
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
        shopName = ""; blend = ""; countryName = ""; farmName = ""; grade = ""; roastLevel = ""
        aromarating = 0; memo = ""; bitternessrating = 0
        acidityrating = 0; bodyrating = 0; sweetnessrating = 0; logImages = []
        selectedAroma = ""
        selectedItems = []; scale = 1.0; offset = .zero
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
