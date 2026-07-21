//
//  ProfileViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/18.
//

import Observation
import SwiftUI
import PhotosUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

@Observable
class ProfileViewModel {
    private var db: Firestore
    
    init() {
        self.db = Firestore.firestore()
        
        // --- 初期化時の代入 ---
        self.userName = user.userName
        self.selfIntroduction = user.selfIntroduction
    }
    
    // 💡 修正後の User モデルの構造（道具のプロパティを含む）に合わせて初期化
    var user: User = User(
        id: nil,
        userNo: 1,
        userName: "",
        email: "",
        selfIntroduction: "",
        userAge: 0,
        prefecture: "",
        favoriteCoffee: "",
        probitter: 0,
        proacidity: 0,
        probody: 0,
        proaroma: 0,
        proflavor: "",
        dripper: "",
        paperFilter: "",
        kettle: "",
        server: "",
        scale: "",
        mill: "",
        grinder: "",
        espressoMachine: "",
        frenchPress: "",
        profileImageUrl: nil,
        favoriteCoffeeImageUrl: nil
    )
    
    var logs: [Log] = []
    var userName: String = ""
    var selfIntroduction: String = ""
    var favoriteCoffee: String = ""
    var userNo: Int = 1
    var favoriteCoffeeImage: UIImage?
    var profileImage: UIImage?
    var probitter: Int = 0
    var proacidity: Int = 0
    var probody: Int = 0
    var proaroma: Int = 0
    var proflavor: String = ""
    var profileImageUrl: String? = nil
    var favoriteCoffeeImageUrl: String? = nil
    
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    
    var myLogs: [Log] {
        let currentUid = Auth.auth().currentUser?.uid
        return logs.filter { $0.userId == currentUid }
    }
    
    // 道具の定義
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
    
    var isProfileEditSheet: Bool = false
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
    
    @MainActor
    func loadProfile(uid: String) async {
        do {
            let fetchedUser = try await db.collection("users").document(uid).getDocument(as: User.self)
            self.user = fetchedUser
            self.userName = fetchedUser.userName
            self.selfIntroduction = fetchedUser.selfIntroduction
            self.profileImageUrl = fetchedUser.profileImageUrl
            
            // 💡 必要であれば道具や他のプロパティもここで同期できます
            self.dripper = fetchedUser.dripper
            self.paperFilter = fetchedUser.paperFilter
            self.kettle = fetchedUser.kettle
            self.server = fetchedUser.server
            self.scale = fetchedUser.scale
            self.mill = fetchedUser.mill
            self.grinder = fetchedUser.grinder
            self.espressoMachine = fetchedUser.espressoMachine
            self.frenchPress = fetchedUser.frenchPress
            
        } catch {
            print("読み込み失敗: \(error)")
        }
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
