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
        self.profileImage = user.profileImage
    }
    var user: User = User(userNo: 1, userName: "", selfIntroduction: "",userAge: 0, birthPlace: "",favoriteCoffee: "",profileImage: nil,probitter: 0, proacidity: 0, probody: 0, proaroma: 0, proflavor: "")
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
        self.user = User(
            userNo: self.user.userNo,
            userName: self.userName,
            selfIntroduction: self.selfIntroduction,
            userAge: self.userAge,
            birthPlace: self.user.birthPlace,
            favoriteCoffee: self.user.favoriteCoffee,
            profileImage: self.profileImage,
            probitter: self.user.probitter,
            proacidity: self.user.proacidity,
            probody: self.user.probody,
            proaroma: self.user.proaroma,
            proflavor: self.user.proflavor
        )
        
        viewModel.synchronizeMyProfile(with: self.user)
    }
    
    //    //プロフィール数字情報
    //    func profileStat(count: String, label: String) -> some View {
    //        VStack {
    //            Text(count)
    //                .font(.headline)
    //            Text(label)
    //                .font(.caption)
    //                .foregroundColor(.gray)
    //        }
    //        .frame(maxWidth: .infinity) // 均等に並ぶように幅を広げる
    //    }
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
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
