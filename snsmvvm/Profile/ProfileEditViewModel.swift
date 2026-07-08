//
//  ProfileEditViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/08.
//

import Observation
import SwiftUI
import PhotosUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

@Observable
class ProfileEditViewModel {
    private var db: Firestore
    
    init() {
        self.db = Firestore.firestore()
        
        self.userName = user.userName
        self.selfIntroduction = user.selfIntroduction
    }
    
    var user: User = User(
        id: nil, // idは最初はnilでOK
        userNo: 1,
        userName: "",
        selfIntroduction: "",
        userAge: 0,
        prefecture: "",
        favoriteCoffee: "",
        probitter: 0,
        proacidity: 0,
        probody: 0,
        proaroma: 0,
        proflavor: "",
        profileImageUrl: nil, // String? なので nil でOK
        favoriteCoffeeImageUrl: nil
    )
    
    var logs: [Log] = []
    var userName: String = ""
    var selfIntroduction: String = ""
    var userAge: Int = 0
    var isShowingAgePicker: Bool = false
    
    var favoriteCoffee: String = ""
    var userNo: Int = 1
    var isProfileEditSheet: Bool = false
    var favoriteCoffeeImage: UIImage?
    var profileImage:  UIImage?
    var probitter: Int = 0
    var proacidity: Int = 0
    var probody: Int = 0
    var proaroma: Int = 0
    var proflavor: String = ""
    var profileImageUrl: String? = nil
    var favoriteCoffeeImageUrl: String? = nil
    
    func updateUser() {
        var user: User = User(
            id: nil, // idは最初はnilでOK
            userNo: 1,
            userName: "",
            selfIntroduction: "",
            userAge: 0,
            prefecture: "",
            favoriteCoffee: "",
            probitter: 0,
            proacidity: 0,
            probody: 0,
            proaroma: 0,
            proflavor: "",
            profileImageUrl: nil, // String? なので nil でOK
            favoriteCoffeeImageUrl: nil
        )
    }
    
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    
    var selectedCoffeeItem : PhotosPickerItem? {
        didSet{ Task { await loadCoffeeImage() }
        }
    }
    var selectedProfileItem : PhotosPickerItem? {
        didSet{ Task { await loadProfileImage() } }
    }
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
    
    //toolの定義
    var dripper: String = ""
    var paperFilter: String = ""
    var kettle: String = ""
    var server: String = ""
    var scale: String = ""
    var mill: String = ""
    var grinder: String = ""
    var espressoMachine: String = ""
    var frenchPress: String = ""
    var toolImage: UIImage?
    
    @MainActor
    func uploadProfileAndSave(uid: String) async throws {
        // 1. 画像がセットされていればアップロード
        var imageUrl: String? = self.user.profileImageUrl // 元のURLを保持
        
        if let image = profileImage, let data = image.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
            
            // Storage にアップロード
            _ = try await storageRef.putDataAsync(data)
            
            // アップロードした画像のダウンロードURLを取得
            imageUrl = try await storageRef.downloadURL().absoluteString
        }
        
        // 2. Firestore に保存するデータを作成
        var data: [String: Any] = [
            "userName": userName,
            "selfIntroduction": selfIntroduction,
            "userAge": userAge,
            "prefecture#": prefecture,
            "favoriteCoffee": favoriteCoffee,
            "probitter": probitter,
            "proacidity": proacidity,
            "probody": probody,
            "proaroma": proaroma,
            "proflavor": proflavor
        ]
        
        // URLがある場合のみ追加
        if let url = imageUrl {
            data["profileImageUrl"] = url
            self.profileImageUrl = url // ViewModelのプロパティも更新
        }
        
        // 3. Firestore に保存
        try await db.collection("users").document(uid).setData(data, merge: true)
        
        // 4. Userモデルを更新
        self.user.profileImageUrl = imageUrl
        updateUser()
    }
    
    func loadProfileImageFromUrl() {
        guard let urlString = user.profileImageUrl, let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.profileImage = image
                    }
                }
            } catch {
                print("❌ 画像のロード失敗: \(error)")
            }
        }
    }
}
