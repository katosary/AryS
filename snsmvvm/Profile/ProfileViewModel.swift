//
//  5ProfileViewModel.swift
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
    // 1. db をオプショナル、または後から代入する形にする
    private var db: Firestore
    
    init() {
        // 2. init 内で初期化する
        self.db = Firestore.firestore()
        
        // --- 既存の初期化処理 ---
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
    
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    
    var myLogs: [Log] {
        let currentUid = Auth.auth().currentUser?.uid
        return logs.filter { $0.userId == currentUid }
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
            let user = try await db.collection("users").document(uid).getDocument(as: User.self)
            self.user = user
            self.userName = user.userName
            self.selfIntroduction = user.selfIntroduction
            self.profileImageUrl = user.profileImageUrl
            
            // 💡 URLがある場合は、必要に応じてここで画像をフェッチする処理を追加可能
            // 基本はView側で AsyncImage(url: URL(string: user.profileImageUrl ?? "")) を使うのがおすすめ
            
        } catch {
            print("読み込み失敗: \(error)")
        }
    }
    
    // ProfileViewModel.swift に追加
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
