//
//  5ProfileViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/18.
//

import Observation
import SwiftUI
import PhotosUI
import FirebaseCore       // Firebase自体の初期化（configure）に必要
import FirebaseFirestore  // Firestoreのデータベース操作に必要
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
        birthPlace: "",
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
    let ages: [Int] = Array(18...100)
    var birthPlace: String = ""
    var isShowingBirthPlacePicker: Bool = false
    let prefectures: [String] = [
        "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
        "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
        "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県",
        "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県",
        "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県",
        "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県",
        "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
    ]
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
    
    var selectedCoffeeItem : PhotosPickerItem? {
        didSet{ Task { await loadCoffeeImage() }
        }
    }
    var selectedProfileItem : PhotosPickerItem? {
        didSet{ Task { await loadProfileImage() } }
    }
    
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
    
    
    func updateUser(viewModel: ViewModel) {
        // 💡 Userの初期化を、プロパティ名を指定した新しい形式に変更
        self.user = User(
            userNo: self.user.userNo,
            userName: self.userName,
            selfIntroduction: self.selfIntroduction,
            userAge: self.userAge,
            birthPlace: self.birthPlace,
            favoriteCoffee: self.favoriteCoffee,
            probitter: self.probitter,
            proacidity: self.proacidity,
            probody: self.probody,
            proaroma: self.proaroma,
            proflavor: self.proflavor,
            profileImageUrl: self.profileImageUrl, // 💡 新しいプロパティ
            favoriteCoffeeImageUrl: nil // 💡 必要に応じて
        )
        
        viewModel.synchronizeMyProfile(with: self.user)
    }
    

    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
    
    @MainActor
    func uploadProfileAndSave(uid: String, viewModel: ViewModel) async throws {
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
            "birthPlace": birthPlace,
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
        updateUser(viewModel: viewModel)
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
    
    @MainActor
    private func loadCoffeeImage() async {
        guard let data = try? await selectedCoffeeItem?.loadTransferable(type: Data.self) else { return }
        favoriteCoffeeImage = UIImage(data: data)
    }
    @MainActor
    private func loadProfileImage() async {
        guard let data = try? await selectedProfileItem?.loadTransferable(type: Data.self) else { return }
        profileImage = UIImage(data: data)
    }
}
