//
//  StoreProductAddViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI
import Observation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@Observable
class StoreProductAddViewModel {
    var formViewModel: StoreProductFormViewModel
    var isSaving = false
    
    init(product: Product) {
        self.formViewModel = StoreProductFormViewModel(product: product)
    }
    
    func saveProduct(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: ユーザーがログインしていません")
            completion(false)
            return
        }
        print("DEBUG: ログインUID: \(uid)")
        isSaving = true
        
        let images = formViewModel.productImages
        guard let image = images.first else {
            print("DEBUG: 画像なしでFirestore保存へ進みます")
            uploadToFirestore(imageUrl: nil, storeId: uid, completion: completion)
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("DEBUG: 画像のJPEG変換に失敗しました")
            Task { @MainActor in self.isSaving = false }
            completion(false)
            return
        }
        
        let filename = NSUUID().uuidString + ".jpg"
        let ref = Storage.storage().reference().child("product_images").child(filename)
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Storageアップロード失敗: \(error.localizedDescription)")
                Task { @MainActor in
                    self.isSaving = false
                    completion(false)
                }
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: ダウンロードURL取得失敗: \(error.localizedDescription)")
                    Task { @MainActor in
                        self.isSaving = false
                        completion(false)
                    }
                    return
                }
                print("DEBUG: 画像アップロード成功 URL: \(url?.absoluteString ?? "")")
                Task { @MainActor in
                    self.uploadToFirestore(imageUrl: url?.absoluteString, storeId: uid, completion: completion)
                }
            }
        }
    }
    
    private func uploadToFirestore(imageUrl: String?, storeId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let isBlend = formViewModel.isBlend
        
        let finalCountryName: String
        if isBlend {
            let countries = [formViewModel.blendCountry1, formViewModel.blendCountry2, formViewModel.blendCountry3].filter { !$0.isEmpty }
            finalCountryName = countries.joined(separator: ", ")
        } else {
            finalCountryName = formViewModel.countryName
        }
        
        let productData: [String: Any] = [
            "storeId": storeId,
            "storeName": "",
            "productName": isBlend ? formViewModel.blendName : formViewModel.productName,
            "isBlend": isBlend,
            "countryName": finalCountryName,
            "blendCountry1": isBlend ? formViewModel.blendCountry1 : "",
            "blendCountry2": isBlend ? formViewModel.blendCountry2 : "",
            "blendCountry3": isBlend ? formViewModel.blendCountry3 : "",
            "farmName": isBlend ? "" : formViewModel.farmName,
            "grade": isBlend ? "" : formViewModel.grade,
            "roastLevel": isBlend ? "" : formViewModel.roastLevel,
            "price": Int(formViewModel.priceText) ?? 0,
            "greenBeanCost": Int(formViewModel.greenBeanText) ?? 0,
            "packagingCost": Int(formViewModel.packagingText) ?? 0,
            "shippingCost": Int(formViewModel.shippingText) ?? 0,
            "description": formViewModel.descriptionText,
            "imageUrl": imageUrl ?? "",
            "createdAt": Date()
        ]
        
        db.collection("products").addDocument(data: productData) { error in
            Task { @MainActor in
                self.isSaving = false
                if let error = error {
                    print("商品登録失敗: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
