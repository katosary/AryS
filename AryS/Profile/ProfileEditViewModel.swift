//
//  ProfileEditViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/28.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

@Observable
class ProfileEditViewModel {
    var user: User
    
    // 入力項目（ViewのBinding用）
    var userName: String = ""
    var selfIntroduction: String = ""
    var userAge: Int = 0
    var userPrefecture: String = ""
    var favoriteCoffee: String = ""
    
    // 評価（コーヒーの好み）
    var probitter: Int = 0
    var proacidity: Int = 0
    var probody: Int = 0
    var prosweetness: Int = 0
    var proflavor: Int = 0
    
    // フレーバー選択用プロパティ
    var selectedFlavors: [String] = []
    
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
    
    // 道具
    var dripper: String = ""
    var paperFilter: String = ""
    var kettle: String = ""
    var server: String = ""
    var scale: String = ""
    var mill: String = ""
    var grinder: String = ""
    var espressoMachine: String = ""
    var frenchPress: String = ""
    
    // 画像用
    var profileImage: UIImage? = nil
    var selectedProfileItem: PhotosPickerItem? {
        didSet { Task { await loadImage(from: selectedProfileItem, isProfile: true) } }
    }
    
    var favoriteCoffeeImage: UIImage? = nil
    var selectedCoffeeItem: PhotosPickerItem? {
        didSet { Task { await loadImage(from: selectedCoffeeItem, isProfile: false) } }
    }
    
    var profileImageUrl: String? = nil
    var favoriteToolImageUrl: String? = nil
    
    var isShowingAgePicker: Bool = false
    var isShowingPrefecturePicker: Bool = false
    
    let maxRating = 5
    let onColor = Color.orange
    let offColor = Color.gray.opacity(0.3)
    
    private let db = Firestore.firestore()
    
    // クロップ画面制御用（プロフィール用）
    var isShowingImageCropView: Bool = false
    var tempSelectedUIImage: UIImage? = nil
    
    // クロップ画面制御用（お気に入りの道具用）
    var isShowingCoffeeCropView: Bool = false
    var tempSelectedCoffeeUIImage: UIImage? = nil
    
    init(user: User) {
        self.user = user
        configure(with: user)
    }
    
    @MainActor
    func configure(with user: User) {
        self.user = user
        self.userName = user.userName
        self.selfIntroduction = user.selfIntroduction
        self.userAge = user.userAge
        self.userPrefecture = user.prefecture
        self.favoriteCoffee = user.favoriteCoffee
        
        self.probitter = user.probitter
        self.proacidity = user.proacidity
        self.probody = user.probody
        self.prosweetness = user.prosweetness
        self.proflavor = user.proflavor
        
        self.selectedFlavors = user.flavorTags
        
        self.dripper = user.dripper
        self.paperFilter = user.paperFilter
        self.kettle = user.kettle
        self.server = user.server
        self.scale = user.scale
        self.mill = user.mill
        self.grinder = user.grinder
        self.espressoMachine = user.espressoMachine
        self.frenchPress = user.frenchPress
        
        self.profileImageUrl = user.profileImageUrl
        self.favoriteToolImageUrl = user.favoriteToolImageUrl
    }
    
    private func loadImage(from item: PhotosPickerItem?, isProfile: Bool) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        
        await MainActor.run {
            if isProfile {
                self.tempSelectedUIImage = uiImage
                self.isShowingImageCropView = true
            } else {
                self.tempSelectedCoffeeUIImage = uiImage
                self.isShowingCoffeeCropView = true
            }
        }
    }
    
    @MainActor
    func loadProfileImageFromUrl() {
        guard let urlString = user.profileImageUrl, let url = URL(string: urlString) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) { self.profileImage = uiImage }
            } catch {
                print("画像の読み込みに失敗しました: \(error)")
            }
        }
    }
    
    @MainActor
    func loadFavoriteCoffeeImageFromUrl() {
        guard let urlString = user.favoriteToolImageUrl, let url = URL(string: urlString) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) { self.favoriteCoffeeImage = uiImage }
            } catch {
                print("カバー画像の読み込みに失敗しました: \(error)")
            }
        }
    }
    
    @MainActor
    func uploadProfileAndSave(uid: String) async throws -> User {
        var imageUrl: String? = self.user.profileImageUrl
        if let image = profileImage, let data = image.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
            _ = try await storageRef.putDataAsync(data)
            let rawUrlString = try await storageRef.downloadURL().absoluteString
            imageUrl = rawUrlString
        }
        
        var toolImageUrl: String? = self.user.favoriteToolImageUrl
        if let image = favoriteCoffeeImage, let data = image.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage().reference().child("favorite_tool_images/\(uid).jpg")
            _ = try await storageRef.putDataAsync(data)
            let rawUrlString = try await storageRef.downloadURL().absoluteString
            toolImageUrl = rawUrlString
        }
        
        self.user.userName = userName
        self.user.selfIntroduction = selfIntroduction
        self.user.userAge = userAge
        self.user.prefecture = userPrefecture
        self.user.favoriteCoffee = favoriteCoffee
        self.user.probitter = probitter
        self.user.proacidity = proacidity
        self.user.probody = probody
        self.user.prosweetness = prosweetness
        self.user.proflavor = proflavor
        
        self.user.flavorTags = selectedFlavors
        
        self.user.dripper = dripper
        self.user.paperFilter = paperFilter
        self.user.kettle = kettle
        self.user.server = server
        self.user.scale = scale
        self.user.mill = mill
        self.user.grinder = grinder
        self.user.espressoMachine = espressoMachine
        self.user.frenchPress = frenchPress
        
        if let url = imageUrl { self.user.profileImageUrl = url }
        if let url = toolImageUrl { self.user.favoriteToolImageUrl = url }
        
        let updateData: [String: Any] = [
            "userName": self.user.userName,
            "selfIntroduction": self.user.selfIntroduction,
            "userAge": self.user.userAge,
            "prefecture": self.user.prefecture,
            "favoriteCoffee": self.user.favoriteCoffee,
            "probitter": self.user.probitter,
            "proacidity": self.user.proacidity,
            "probody": self.user.probody,
            "prosweetness": self.user.prosweetness,
            "proflavor": self.user.proflavor,
            "flavorTags": self.user.flavorTags,
            "dripper": self.user.dripper,
            "paperFilter": self.user.paperFilter,
            "kettle": self.user.kettle,
            "server": self.user.server,
            "scale": self.user.scale,
            "mill": self.user.mill,
            "grinder": self.user.grinder,
            "espressoMachine": self.user.espressoMachine,
            "frenchPress": self.user.frenchPress,
            "profileImageUrl": self.user.profileImageUrl ?? "",
            "favoriteToolImageUrl": self.user.favoriteToolImageUrl ?? ""
        ]
        
        try await db.collection("users").document(uid).setData(updateData, merge: true)
        return self.user
    }
}
