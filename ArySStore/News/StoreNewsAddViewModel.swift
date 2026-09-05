//
//  StoreNewsAddViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI
import Observation
//import FirebaseFirestore
//import FirebaseAuth

@Observable
@MainActor
final class StoreNewsAddViewModel {
    var title = ""
    var subtitle = ""
    var bodyText = ""
    var linkUrl = ""
    // プレビュー用や画像選択用のプロパティ（必要に応じて拡張）
    var selectedImage: UIImage? = nil
    
    var isLoading = false
    var errorMessage = ""
    
    // 入力内容が有効かどうかの判定
    var isValid: Bool {
        !title.isEmpty && !bodyText.isEmpty
    }
    
    // NEWSを配信する処理（Firestore連携用テンプレート）
    func postNews(completion: @escaping () -> Void) {
//        guard let storeUid = Auth.auth().currentUser?.uid else {
//            errorMessage = "ログイン中の店舗情報が見つかりません"
//            return
//        }
//
//        isLoading = true
//        errorMessage = ""
//
//        let db = Firestore.firestore()
//        let newsData: [String: Any] = [
//            "storeId": storeUid,
//            "title": title,
//            "subtitle": subtitle,
//            "bodyText": bodyText,
//            "linkUrl": linkUrl,
//            "createdAt": FieldValue.serverTimestamp()
//        ]
//
//        db.collection("news").addDocument(data: newsData) { [weak self] error in
//            guard let self = self else { return }
//            self.isLoading = false
//
//            if let error = error {
//                self.errorMessage = "投稿エラー: \(error.localizedDescription)"
//            } else {
//                self.clearForm()
//                completion()
//            }
//        }
        
        // Firebase未連携時のモック動作として即座に完了させる
        clearForm()
        completion()
    }
    
    func clearForm() {
        title = ""
        subtitle = ""
        bodyText = ""
        linkUrl = ""
        selectedImage = nil
    }
}
