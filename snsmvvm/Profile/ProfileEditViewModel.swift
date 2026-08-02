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
    var favoriteCoffee: String = ""
    
    // 評価（コーヒーの好み）
    var probitter: Int = 0
    var proacidity: Int = 0
    var probody: Int = 0
    var proaroma: Int = 0
    var proflavor: String = ""
    
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
    var favoriteCoffeeImageUrl: String? = nil
    
    // ピッチャーの表示フラグ
    var isShowingAgePicker: Bool = false
    var isShowingPrefecturePicker: Bool = false
    
    let maxRating = 5
    let onColor = Color.orange
    let offColor = Color.gray.opacity(0.3)
    
    private let db = Firestore.firestore()
    
    // 既存のUserデータを受け取って初期化
    init(user: User) {
        self.user = user
        configure(with: user)
    }
    
    // デフォルトイニシャライザ
    init() {
        self.user = User(
            id: "", userName: "", email: "", selfIntroduction: "",
            userAge: 0, prefecture: "", favoriteCoffee: "",
            probitter: 0, proacidity: 0, probody: 0, proaroma: 0, proflavor: "",
            dripper: "", paperFilter: "", kettle: "", server: "", scale: "",
            mill: "", grinder: "", espressoMachine: "", frenchPress: "",
            profileImageUrl: nil, favoriteCoffeeImageUrl: nil
        )
    }
    
    /// 💡 シート表示時などに最新の User 情報で各プロパティを再セットする処理
    @MainActor
    func configure(with user: User) {
        self.user = user
        self.userName = user.userName
        self.selfIntroduction = user.selfIntroduction
        self.userAge = user.userAge
        self.favoriteCoffee = user.favoriteCoffee
        
        self.probitter = user.probitter
        self.proacidity = user.proacidity
        self.probody = user.probody
        self.proaroma = user.proaroma
        self.proflavor = user.proflavor
        
        self.dripper = user.dripper ?? ""
        self.paperFilter = user.paperFilter ?? ""
        self.kettle = user.kettle ?? ""
        self.server = user.server ?? ""
        self.scale = user.scale ?? ""
        self.mill = user.mill ?? ""
        self.grinder = user.grinder ?? ""
        self.espressoMachine = user.espressoMachine ?? ""
        self.frenchPress = user.frenchPress ?? ""
        
        self.profileImageUrl = user.profileImageUrl
        self.favoriteCoffeeImageUrl = user.favoriteCoffeeImageUrl
    }
    
    // 写真選択時のロード処理
    private func loadImage(from item: PhotosPickerItem?, isProfile: Bool) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        
        await MainActor.run {
            if isProfile {
                self.profileImage = uiImage
            } else {
                self.favoriteCoffeeImage = uiImage
            }
        }
    }
    
    // 既存のプロフィール画像をURLから読み込む処理
    @MainActor
    func loadProfileImageFromUrl() {
        guard let urlString = user.profileImageUrl, let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    self.profileImage = uiImage
                }
            } catch {
                print("画像の読み込みに失敗しました: \(error)")
            }
        }
    }
    
    @MainActor
    func uploadProfileAndSave(uid: String) async throws -> User { // 💡 戻り値として更新後のUserを返す
        // 1. プロフィール画像のアップロード処理
        var imageUrl: String? = self.user.profileImageUrl
        if let image = profileImage, let data = image.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
            _ = try await storageRef.putDataAsync(data)
            let rawUrlString = try await storageRef.downloadURL().absoluteString
            let timestamp = Int(Date().timeIntervalSince1970)
            imageUrl = "\(rawUrlString)?v=\(timestamp)"
        }

        // 2. ViewModel内のプロパティから最新の入力内容を同期
        self.user.userName = userName
        self.user.selfIntroduction = selfIntroduction
        self.user.userAge = userAge
        self.user.favoriteCoffee = favoriteCoffee
        self.user.probitter = probitter
        self.user.proacidity = proacidity
        self.user.probody = probody
        self.user.proaroma = proaroma
        self.user.proflavor = proflavor
        self.user.dripper = dripper
        self.user.paperFilter = paperFilter
        self.user.kettle = kettle
        self.user.server = server
        self.user.scale = scale
        self.user.mill = mill
        self.user.grinder = grinder
        self.user.espressoMachine = espressoMachine
        self.user.frenchPress = frenchPress
        if let url = imageUrl {
            self.user.profileImageUrl = url
        }

        // 3. Firestoreに更新データを送る
        let updateData: [String: Any] = [
            "userName": self.user.userName,
            "selfIntroduction": self.user.selfIntroduction,
            "userAge": self.user.userAge,
            "prefecture": self.user.prefecture,
            "favoriteCoffee": self.user.favoriteCoffee,
            "probitter": self.user.probitter,
            "proacidity": self.user.proacidity,
            "probody": self.user.probody,
            "proaroma": self.user.proaroma,
            "proflavor": self.user.proflavor,
            "dripper": self.user.dripper ?? "",
            "paperFilter": self.user.paperFilter ?? "",
            "kettle": self.user.kettle ?? "",
            "server": self.user.server ?? "",
            "scale": self.user.scale ?? "",
            "mill": self.user.mill ?? "",
            "grinder": self.user.grinder ?? "",
            "espressoMachine": self.user.espressoMachine ?? "",
            "frenchPress": self.user.frenchPress ?? "",
            "profileImageUrl": self.user.profileImageUrl ?? ""
        ]

        try await db.collection("users").document(uid).setData(updateData, merge: true)
        
        return self.user // 💡 更新された User を返す
    }
}
