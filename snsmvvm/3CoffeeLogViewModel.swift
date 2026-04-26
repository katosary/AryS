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
    var farmName: String = ""
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
    
    var averagebitternessrating: Double {
        return Double(bitternessrating1 + bitternessrating2) / 2.0
    }
    
    var selectedItem : PhotosPickerItem? {
        didSet{ Task { await loadImage() } }
    }
    var logImage: UIImage?
    var user: User = User(userNo: 0, userName: "",selfIntroduction:"", favoriteCoffee: "",probitter: 0,proacidity: 0,probody: 0,proaroma: 0)
    
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
    
    //投稿削除ボタン
    func deleteLog(targetPost: Log) {
        logs.removeAll {$0.id == targetPost.id }
    }
    
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
    
