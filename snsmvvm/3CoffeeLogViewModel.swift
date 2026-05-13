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
    var logs: [Log] = []//SendMessageViewで入力された内容を保存している配列。　postsはその配列の名前
    var shopName: String = ""
    var countryName: String = ""
    var isShowingCountryPicker: Bool = false
    // データの定義（辞書形式などで管理すると扱いやすいです）
    let regions = [
        "中南米": ["ブラジル", "コロンビア", "ホンジュラス", "グアテマラ", "ペルー", "メキシコ", "ニカラグア", "コスタリカ", "エルサルバドル", "パナマ", "ボリビア", "エクアドル", "ジャマイカ", "キューバ", "ドミニカ共和国"],
        "アフリカ": ["エチオピア", "ケニア", "タンザニア", "ウガンダ", "ルワンダ", "ブルンジ", "コートジボワール", "コンゴ民主共和国", "カメルーン", "マラウイ", "ザンビア", "ジンバブエ"],
        "中東": ["イエメン", "サウジアラビア"],
        "アジア": ["ベトナム", "インドネシア", "インド", "ラオス", "タイ", "ミャンマー", "東ティモール", "フィリピン", "中国（雲南省）"],
        "その他（オセアニア・北米・島嶼部）": ["パプアニューギニア", "オーストラリア", "アメリカ合衆国（ハワイ・プエルトリコ）", "ニューカレドニア", "セントヘレナ島"]
    ]
    
    // リージョンの並び順を指定（辞書は順序が不定なため）
    let regionOrder = ["中南米", "アフリカ", "中東", "アジア", "その他（オセアニア・北米・島嶼部）"]
    
    var farmName: String = ""
    var isShowingRoastPicker: Bool = false
    // 焙煎度の選択肢リスト
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
    
    // ドラッグ位置を保持する変数
    var currentOffsetX: CGFloat = 0
    var currentOffsetY: CGFloat = 0
    
    var tagX: CGFloat = 0
    var tagY: CGFloat = 0
    
    // ドラッグ終了時に呼ばれる関数を、特定のLogIDだけでなく「現在編集中のもの」に対応させる
    func updateCurrentPosition(offset: CGSize) {
        self.currentOffsetX = offset.width
        self.currentOffsetY = offset.height
    }
    
    var averagebitternessrating: Double {
        return Double(bitternessrating1 + bitternessrating2) / 2.0
    }
    
    var selectedItem : PhotosPickerItem? {
        didSet{ Task { await loadImage() } }
    }
    var logImage: UIImage?
    var user: User = User(userNo: 0, userName: "",selfIntroduction:"", favoriteCoffee: "",probitter: 0,proacidity: 0,probody: 0,proaroma: 0,proflavor: "")
    
    //投稿追加
    func addLog(currentUser: User) {
        let newLog = Log (
            user: currentUser,
            shopName: shopName,
            countryName :countryName,
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
            logImage: logImage,
            textOffset: CGSize(width: currentOffsetX, height: currentOffsetY),
            tagX: currentOffsetX,
            tagY: currentOffsetY
        )
        
        logs.append(newLog)
        
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
        logImage = nil
        selectedItem = nil
        currentOffsetX = 0 // 次の投稿のために位置もリセット
        currentOffsetY = 0
    }
    
    //投稿編集ボタン
    func updateLog(targetPost: Log) {
        if let id = logs.firstIndex(where: { $0.id == targetPost.id }) {
            // その場所の内容を、保存しておいた editingText で上書きする
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
    
    //投稿削除ボタン
    func deleteLog(targetPost: Log) {
        logs.removeAll {$0.id == targetPost.id }
    }
    
    var textOffset: CGSize = .zero
    // --- 👈 追加：ドラッグ中の位置を一時保存する変数 ---
    
    //投稿星評価
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
    
    // 選択されたアイテムを UIImage に変換
    @MainActor
    private func loadImage() async {
        guard let data = try? await selectedItem?.loadTransferable(type: Data.self) else { return }
        logImage = UIImage(data: data)
    }
}


//removeAll は「条件に合うものを全部消す」という命令
//firstIndex(where:) は「条件に合うものがどこ（何番目）にあるか教えて」という命令

