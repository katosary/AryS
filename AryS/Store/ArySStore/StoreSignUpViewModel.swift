//
//  StoreSignUpViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/09/06.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Observable
class StoreSignUpViewModel {
    var currentStep = 1
    let totalSteps = 3
    
    // ステップ 1: 基本・店舗情報
    var storeName = ""
    var postalCode = ""
    var prefecture = ""
    var city = ""
    var streetNumber = ""
    var buildingName = ""
    var phoneNumber = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var isFetchingAddress = false
    
    // ステップ 2: 焙煎士情報 ＆ アンケート
    var roasterName = ""
    var roastingExperience = ""
    var roasterBio = ""
    var roastingMachine = ""
    var selectedBusinessModel = ""
    var selectedRevenue = ""
    var desiredPlatformFeatures = ""
    var futureExpectations = ""
    
    // ステップ 3: 規約同意
    var isTermsAccepted = false
    var isPrivacyAccepted = false
    
    // 状態管理
    var errorMessage = ""
    var isLoading = false
    var isVerificationNoticePresented = false // 画面遷移用フラグ
    
    let brandBackgroundColor = Color(red: 89/255, green: 61/255, blue: 43/255)
    private let db = Firestore.firestore()
    
    let termsURL = URL(string: "https://sites.google.com/d/1hgwbPGg6Dz7nm3GNFxWw_1AsttJceEXx/p/1WAmRUDO552YbIq6X9fgbQnP0p8Bln8fR/edit")!
    let privacyURL = URL(string: "https://sites.google.com/d/1yVKs4XMg78E3NSHHxruuzdQoAKV8XsyU/p/1QYho7F0qTFM6MpUOKbeMFJvDXcHYBViv/edit")!

    // ステップごとのバリデーション
    func isCurrentStepValid() -> Bool {
        switch currentStep {
        case 1:
            let isPhoneValid = phoneNumber.count == 11 && phoneNumber.hasPrefix("090")
            
            return !storeName.isEmpty &&
                   !postalCode.isEmpty &&
                   !prefecture.isEmpty &&
                   !city.isEmpty &&
                   !streetNumber.isEmpty &&
                   isPhoneValid &&
                   !email.isEmpty &&
                   password.count >= 6 &&
                   password == confirmPassword
        case 2:
            // 必須項目として「名前」と「ビジネスモデル」「売上目安」をチェック
            return !roasterName.isEmpty &&
                   !selectedBusinessModel.isEmpty &&
                   !selectedRevenue.isEmpty
        case 3:
            return isTermsAccepted && isPrivacyAccepted
        default:
            return false
        }
    }
    
    func nextStep() {
        if currentStep < totalSteps {
            currentStep += 1
            errorMessage = ""
        }
    }
    
    func previousStep() {
        if currentStep > 1 {
            currentStep -= 1
            errorMessage = ""
        }
    }
    
    func fetchAddressByPostalCode() {
        let cleanPostalCode = postalCode.filter { $0.isNumber }
        guard cleanPostalCode.count == 7 else { return }
        
        isFetchingAddress = true
        errorMessage = ""
        
        guard let url = URL(string: "https://zipcloud.ibsnet.co.jp/api/search?zipcode=\(cleanPostalCode)") else {
            isFetchingAddress = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isFetchingAddress = false
                
                if let error = error {
                    self.errorMessage = "住所の取得に失敗しました: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "住所データが見つかりませんでした。"
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let firstResult = results.first {
                        let pref = firstResult["address1"] as? String ?? ""
                        let municipal = firstResult["address2"] as? String ?? ""
                        let town = firstResult["address3"] as? String ?? ""
                        
                        self.prefecture = pref
                        self.city = municipal + town
                    } else {
                        self.errorMessage = "該当する住所が見つかりませんでした。"
                    }
                } catch {
                    self.errorMessage = "住所データの解析に失敗しました。"
                }
            }
        }.resume()
    }
    
    func registerStore(completion: @escaping () -> Void) {
        isLoading = true
        errorMessage = ""
         
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
             
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                return
            }
             
            guard let uid = result?.user.uid else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "ユーザー情報の取得に失敗しました。"
                }
                return
            }
             
            let fullAddress = "〒\(self.postalCode) \(self.prefecture)\(self.city)\(self.streetNumber) \(self.buildingName)"
            let storeData: [String: Any] = [
                "storeName": self.storeName,
                "email": self.email,
                "postalCode": self.postalCode,
                "prefecture": self.prefecture,
                "city": self.city,
                "streetNumber": self.streetNumber,
                "buildingName": self.buildingName,
                "address": fullAddress,
                "phoneNumber": self.phoneNumber,
                // 焙煎士情報
                "roasterName": self.roasterName,
                "roastingExperience": self.roastingExperience,
                "roasterBio": self.roasterBio,
                "roastingMachine": self.roastingMachine,
                // アンケート項目
                "businessModel": self.selectedBusinessModel,
                "estimatedRevenue": self.selectedRevenue,
                "desiredFeatures": self.desiredPlatformFeatures,
                "futureExpectations": self.futureExpectations,
                "createdAt": FieldValue.serverTimestamp()
            ]
             
            self.db.collection("stores").document(uid).setData(storeData) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "店舗情報の保存に失敗しました: \(error.localizedDescription)"
                    }
                    return
                }
                 
                result?.user.sendEmailVerification { emailError in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if let emailError = emailError {
                            self.errorMessage = "確認メールの送信に失敗しました: \(emailError.localizedDescription)"
                        } else {
                            // アラートではなく画面遷移フラグをtrueにする
                            self.isVerificationNoticePresented = true
                            completion()
                        }
                    }
                }
            }
        }
    }
}
