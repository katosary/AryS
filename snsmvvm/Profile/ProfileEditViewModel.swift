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
    
    // 入力項目のプロパティ
    var userName: String = ""
    var selfIntroduction: String = ""
    var userAge: Int = 0
    var prefecture: String = ""
    var favoriteCoffee: String = ""
    
    // 評価（コーヒーの好み）
    var probitter: Int = 3
    var proacidity: Int = 3
    var probody: Int = 3
    var proaroma: Int = 3
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
    
    // ピッチャーの表示フラグなど
    var isShowingAgePicker: Bool = false
    var isShowingPrefecturePicker: Bool = false
    
    let maxRating = 5
    let onColor = Color.orange
    let offColor = Color.gray.opacity(0.3)
    
    private let db = Firestore.firestore()
    
    // 💡 1. 既存のUserデータを受け取って初期化するイニシャライザ
    init(user: User) {
        self.user = user
        self.userName = user.userName
        self.selfIntroduction = user.selfIntroduction
        self.userAge = user.userAge
        self.prefecture = user.prefecture
        self.favoriteCoffee = user.favoriteCoffee
        
        self.probitter = user.probitter
        self.proacidity = user.proacidity
        self.probody = user.probody
        self.proaroma = user.proaroma
        self.proflavor = user.proflavor
        
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
        self.favoriteCoffeeImageUrl = user.favoriteCoffeeImageUrl
    }
    
    // デフォルト（引数なし）のイニシャライザ
    init() {
        self.user = User(
            id: "", userName: "", email: "", selfIntroduction: "",
            userAge: 0, prefecture: "", favoriteCoffee: "",
            probitter: 3, proacidity: 3, probody: 3, proaroma: 3, proflavor: "",
            dripper: "", paperFilter: "", kettle: "", server: "", scale: "",
            mill: "", grinder: "", espressoMachine: "", frenchPress: "",
            profileImageUrl: nil, favoriteCoffeeImageUrl: nil
        )
    }
    
    // 2. 写真選択時のロード処理
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
    
    // 3. 既存のプロフィール画像をURLから読み込む処理
    func loadProfileImageFromUrl() {
        guard let urlString = user.profileImageUrl, let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = uiImage
                }
            }
        }.resume()
    }
    
    // 4. Firestoreへ保存する処理
    @MainActor
    func uploadProfileAndSave(uid: String) async throws {
        var imageUrl: String? = self.user.profileImageUrl
        if let image = profileImage, let data = image.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
            _ = try await storageRef.putDataAsync(data)
            let rawUrlString = try await storageRef.downloadURL().absoluteString
            let timestamp = Int(Date().timeIntervalSince1970)
            imageUrl = "\(rawUrlString)?v=\(timestamp)"
        }
        
        // 💡 プレフィックスのタイポ（#）を修正済み
        var data: [String: Any] = [
            "userName": userName,
            "selfIntroduction": selfIntroduction,
            "userAge": userAge,
            "prefecture": prefecture,
            "favoriteCoffee": favoriteCoffee,
            "probitter": probitter,
            "proacidity": proacidity,
            "probody": probody,
            "proaroma": proaroma,
            "proflavor": proflavor,
            "dripper": dripper,
            "paperFilter": paperFilter,
            "kettle": kettle,
            "server": server,
            "scale": scale,
            "mill": mill,
            "grinder": grinder,
            "espressoMachine": espressoMachine,
            "frenchPress": frenchPress
        ]
        
        if let url = imageUrl {
            data["profileImageUrl"] = url
            self.profileImageUrl = url
        }
        
        try await db.collection("users").document(uid).setData(data, merge: true)
        
        // ローカルのUserモデルも更新
        self.user.userName = userName
        self.user.selfIntroduction = selfIntroduction
        self.user.userAge = userAge
        self.user.prefecture = prefecture
        self.user.profileImageUrl = imageUrl
    }
    
    func image(for number: Int, rating: Int) -> Image {
        return number > rating ? Image(systemName: "star") : Image(systemName: "star.fill")
    }
}
