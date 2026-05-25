//
//  PostViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

//ViewModel
import Observation
import SwiftUI
import PhotosUI

@Observable
class ViewModel {
    var logs: [Log] = []
    var shopName: String = ""
    var countryName: String = ""
    var isShowingCountryPicker: Bool = false
    
    let regions = [
        "中南米": ["ブラジル", "コロンビア", "ホンジュラス", "グアテマラ", "ペルー", "メキシコ", "ニカラグア", "コスタリカ", "エルサルバドル", "パナマ", "ボリビア", "エクアドル", "ジャマイカ", "キューバ", "ドミニカ共和国"],
        "アフリカ": ["エチオピア", "ケニア", "タンザニア", "ウガンダ", "ルワンダ", "ブルンジ", "コートジボワール", "コンゴ民主共和国", "カメルーン", "マラウイ", "ザンビア", "ジンバブエ"],
        "中東": ["イエメン", "サウジアラビア"],
        "アジア": ["ベトナム", "インドネシア", "インド", "ラオス", "タイ", "ミャンマー", "東ティモール", "フィリピン", "中国（雲南省）"],
        "その他（オセアニア・北米・島嶼部）": ["パプアニューギニア", "オーストラリア", "アメリカ合衆国（ハワイ・プエルトリコ）", "ニューカレドニア", "セントヘレナ島"]
    ]
    
    let regionOrder = ["中南米", "アフリカ", "中東", "アジア", "その他（オセアニア・北米・島嶼部）"]
    
    var farmName: String = ""
    var isShowingRoastPicker: Bool = false
    let roastLevels = [
        "ライトロースト", "シナモンロースト",
        "ミディアムロースト", "ハイロースト",
        "シティロースト", "フルシティロースト",
        "フレンチロースト", "イタリアンロースト"
    ]
    var roastLevel: String = ""
    var inputcoffee: String = ""
    var inputcontent: String = ""
    var editingUser: String = ""
    var editingCoffee: String = ""
    var editingFavoCoffee: String = ""
    var editingContent: String = ""
    var iswritingsheet = false
    var isEditSheet: Bool = false
    var aromarating: Int = 0
    var aromaComment: String = ""
    var bitternessrating1: Int = 0
    var acidityrating1: Int = 0
    var bodyrating1: Int = 0
    var bitternessrating2: Int = 0
    var acidityrating2: Int = 0
    var bodyrating2: Int = 0
    var maxRating = 5
    var editingRating: Int = 0
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    var selectedPost: Log?
    var selectedTab: Int = 0
    
    var currentOffsetX: CGFloat = 0
    var currentOffsetY: CGFloat = 0
    var tagX: CGFloat = 0
    var tagY: CGFloat = 0
    
    func updateCurrentPosition(offset: CGSize) {
        self.currentOffsetX = offset.width
        self.currentOffsetY = offset.height
    }
    
    var averagebitternessrating: Double {
        return Double(bitternessrating1 + bitternessrating2) / 2.0
    }
    
    // 💡 1枚専用なので、selectedItems から最初の1枚だけを処理するようにしてもOK
    var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            Task {
                await loadImages()
            }
        }
    }
    
    // 入力中のプレビュー用画像
    var logImages: [UIImage] = []
    
    var user: User = User(userNo: 1, userName: "", selfIntroduction: "", userAge: 0, birthPlace: "", favoriteCoffee: "", probitter: 0, proacidity: 0, probody: 0, proaroma: 0, proflavor: "")
    
    // 投稿追加
    func addLog(currentUser: User) {
        // 💡 確実に型が一致するように、Log の定義に合わせて logImages（またはその配列）を渡します
        let newLog = Log(
            user: currentUser,
            shopName: shopName,
            countryName: countryName,
            farmName: farmName,
            roastLevel: roastLevel,
            aromarating: aromarating,
            aromaComment: aromaComment,
            bitternessrating1: bitternessrating1,
            acidityrating1: acidityrating1,
            bodyrating1: bodyrating1,
            bitternessrating2: bitternessrating2,
            acidityrating2: acidityrating2,
            bodyrating2: bodyrating2,
            createdAt: Date(),
            logImages: logImages, // 現在選択されている画像をLogに保存！
            textOffset: CGSize(width: currentOffsetX, height: currentOffsetY),
            tagX: currentOffsetX,
            tagY: currentOffsetY
        )
        
        logs.append(newLog)
        
        // 入力フォームをクリア（ここは今のままで正解です！）
        shopName = ""
        countryName = ""
        farmName = ""
        roastLevel = ""
        aromarating = 0
        aromaComment = ""
        bitternessrating1 = 0
        acidityrating1 = 0
        bodyrating1 = 0
        bitternessrating2 = 0
        acidityrating2 = 0
        bodyrating2 = 0
        logImages = []
        selectedItems = []
        currentOffsetX = 0
        currentOffsetY = 0
    }
    
    func updateLog(targetPost: Log) {
        if let id = logs.firstIndex(where: { $0.id == targetPost.id }) {
            logs[id].countryName = self.editingCoffee
            logs[id].aromarating = self.editingRating
            clearEditingLog()
            self.isEditSheet = false
        }
    }
    
    func clearEditingLog() {
        self.editingCoffee = ""
        self.editingContent = ""
        self.editingRating = 0
    }
    
    func updateLogPosition(id: UUID, offset: CGSize) {
        if let index = logs.firstIndex(where: { $0.id == id }) {
            logs[index].textOffset = offset
        }
    }
    
    func deleteLog(targetPost: Log) {
        logs.removeAll { $0.id == targetPost.id }
    }
    
    var textOffset: CGSize = .zero
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
    
    // 💡 【追加】プロフィールが更新されたら、自分の過去の投稿データを一括更新する
        func synchronizeMyProfile(with updatedUser: User) {
            for index in 0..<logs.count {
                // 投稿のユーザーNOが、更新されたユーザーNOと一致する場合
                if logs[index].user.userNo == updatedUser.userNo {
                    logs[index].user = updatedUser
                }
            }
        }
    
    @MainActor
    private func loadImages() async {
        var loadedImages: [UIImage] = []
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                loadedImages.append(uiImage)
            }
        }
        self.logImages = loadedImages
    }
}
