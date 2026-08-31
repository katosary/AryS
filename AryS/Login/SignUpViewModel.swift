//
//  SignUpViewModel.swift
//  AryS
//
//  Created by katoso on 2026/08/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

final class SignUpViewModel: ObservableObject {
    // 現在のステップ（1〜4）
    @Published var currentStep = 1
    
    // --- 入力データ ---
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = "" // パスワード確認用
    
    // ステップ2: 基本情報
    @Published var name = ""
    @Published var age = 0
    @Published var isShowingAgePicker = false
    @Published var prefecture = ""
    @Published var addressDetail = ""
    @Published var isShowingPrefecturePicker = false
    
    // ステップ3: コーヒーの好み
    @Published var probitter = 0
    @Published var proacidity = 0
    @Published var probody = 0
    @Published var prosweetness = 0
    @Published var proflavor = 0
    @Published var selectedFlavors: [String] = [] // 選択されたフレーバータグ
    
    // 【追加】ステップ4: 利用規約・プライバシーポリシーの同意状態
    @Published var isTermsAccepted = false
    @Published var isPrivacyAccepted = false
    
    // フレーバーの選択肢
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
    let maxRating = 5
    
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    // 登録成功後の確認メール案内アラート制御用
    @Published var showVerificationAlert = false
    
    // LoginViewと共通の背景色（コーヒーブラウン）
    let brandBackgroundColor = Color(red: 89/255, green: 61/255, blue: 43/255)
    
    private let db = Firestore.firestore()
    
    // 各ステップごとの入力バリデーション
    func isCurrentStepValid() -> Bool {
        switch currentStep {
        case 1:
            return !email.isEmpty && password.count >= 6 && password == confirmPassword
        case 2:
            return !name.isEmpty && age > 0 && !prefecture.isEmpty
        case 3:
            // 苦味・酸味・コク・甘味・フレーバーのすべてが0より大きい（選択されている）場合のみ次へ進める
            return probitter > 0 && proacidity > 0 && probody > 0 && prosweetness > 0 && proflavor > 0
        case 4:
            // 【変更】利用規約とプライバシーポリシーの両方に同意している場合のみ「登録する」ボタンを有効化
            return isTermsAccepted && isPrivacyAccepted
        default:
            return false
        }
    }
    
    // 次のステップへ進む
    func nextStep() {
        if currentStep < 4 {
            currentStep += 1
            errorMessage = ""
        }
    }
    
    // 前のステップへ戻る
    func previousStep() {
        if currentStep > 1 {
            currentStep -= 1
            errorMessage = ""
        }
    }
    
    // 最終登録処理
    func registerUser(authManager: AuthManager, completion: @escaping () -> Void) {
        isLoading = true
        errorMessage = ""
         
        authManager.signUp(
            email: email,
            password: password,
            name: name,
            age: age,
            prefecture: prefecture,
            addressDetail: addressDetail,
            probitter: probitter,
            proacidity: proacidity,
            probody: probody,
            prosweetness: prosweetness,
            proflavor: proflavor,
            selectedFlavors: selectedFlavors
        ) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.errorMessage = error
            } else {
                self.showVerificationAlert = true
                completion()
            }
        }
    }
    
    /// サインアップ成功後にプロパティをFirestoreへ保存・更新するメソッド
    func saveCoffeeProfile(uid: String) async throws {
        let fullAddress = prefecture + addressDetail
         
        let initialData: [String: Any] = [
            "userName": name,
            "userAge": age,
            "prefecture": prefecture,
            "address": fullAddress,
            "probitter": probitter,
            "proacidity": proacidity,
            "probody": probody,
            "prosweetness": prosweetness,
            "proflavor": proflavor,
            "flavorTags": selectedFlavors, // ProfileEditViewModel と同じプロパティ名で保存
            "dripper": "",
            "paperFilter": "",
            "kettle": "",
            "server": "",
            "scale": "",
            "mill": "",
            "grinder": "",
            "espressoMachine": "",
            "frenchPress": "",
            "profileImageUrl": "",
            "favoriteToolImageUrl": ""
        ]
         
        try await db.collection("users").document(uid).setData(initialData, merge: true)
    }
}
