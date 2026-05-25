//
//  5ProfileViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/18.
//

import Observation
import SwiftUI
import PhotosUI

@Observable
class ProfileViewModel {
    var user: User = User(userNo: 1, userName: "コーヒー好き", selfIntroduction: "",userAge: 0, birthPlace: "",favoriteCoffee: "",profileImage: UIImage(systemName: "person.circle.fill"),probitter: 0, proacidity: 0, probody: 0, proaroma: 0, proflavor: "")
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
    
    init() {
        // ⭕️ @Observable の init 内では、頭に「_」をつけて代入するのが正しいルールです！
        self._userName = user.userName
        self._selfIntroduction = user.selfIntroduction
        self._profileImage = user.profileImage
    }
    
    
    // ユーザー情報編集
    func updateUser(viewModel: ViewModel) {
        print("--- 🛠 保存ボタン検証 🛠 ---")
        print("① 入力欄から届いた名前(userName): [ \(self.userName) ]")
        print("② 現在のユーザーデータ(user.userName): [ \(self.user.userName) ]")
        
        // ⭕️ ここで入力欄の「self.userName」を使って user を新しく作り直す！
        self.user = User(
            userNo: self.user.userNo,             // 既存の番号をそのまま使う
            userName: self.userName,             // 👈 ここを「self.userName」（加藤）にする！
            selfIntroduction: self.selfIntroduction, // 👈 入力された自己紹介
            userAge: self.user.userAge,
            birthPlace: self.user.birthPlace,
            favoriteCoffee: self.user.favoriteCoffee,
            profileImage: self.profileImage,     // 👈 選んだ写真
            probitter: self.user.probitter,
            proacidity: self.user.proacidity,
            probody: self.user.probody,
            proaroma: self.user.proaroma,
            proflavor: self.user.proflavor
        )
        
        // ⭕️ タイムライン側（mainVM）にも、新しく作った user を叩き込む！
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
