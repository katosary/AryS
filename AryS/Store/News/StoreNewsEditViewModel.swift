//
//  StoreNewsEditViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI
import Observation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@Observable
@MainActor
final class StoreNewsEditViewModel {
    var newsId: String
    var formViewModel: StoreNewsFormViewModel
    var isSaving = false
    
    init(newsId: String, title: String, subtitle: String, bodyText: String, linkUrl: String, imageUrl: String) {
        self.newsId = newsId
        self.formViewModel = StoreNewsFormViewModel(
            title: title,
            subtitle: subtitle,
            bodyText: bodyText,
            linkUrl: linkUrl,
            imageUrl: imageUrl
        )
        
        // 既存の画像をプレビュー用にセット
        if !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: url),
                   let image = UIImage(data: data) {
                    self.formViewModel.selectedImage = image
                }
            }
        }
    }
    
    // 画像が変更されていればFirebase Storageにアップロードし、Firestoreのデータを更新する
    func updateNews(completion: @escaping (Bool) -> Void) {
        isSaving = true
        
        if let image = formViewModel.selectedImage,
           let _ = image.jpegData(compressionQuality: 0.7),
           let _ = URL(string: formViewModel.imageUrl),
           // 新しく選択された画像が既存のURLからロードされたものでない場合のみアップロードする判定も可能ですが、
           // シンプルに毎回アップロードまたは新規選択時のみにする場合は以下のように処理します。
           // ※ここでは「新しい画像ファイルが選ばれてアップロードが必要なケース」を処理します
           !formViewModel.imageUrl.contains("firebase") // 例としての判定、または常にアップロードするなら下記へ
        {
            // ※もし「画像を変更した時だけアップロードしたい」場合は、選択された画像が変更されたかを管理するか、
            // 常に新しいStorageパスに保存して差し替える方法が安全です。
        }
        
        // 新しい画像が選択されていて、それが新規撮影やライブラリから選ばれたUIImageの場合の処理
        if let image = formViewModel.selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.7) {
            
            let filename = NSUUID().uuidString + ".jpg"
            let ref = Storage.storage().reference().child("news_images").child(filename)
            
            ref.putData(imageData, metadata: nil) { [weak self] _, error in
                guard let self = self else { return }
                if error != nil {
                    Task { @MainActor in self.isSaving = false }
                    completion(false)
                    return
                }
                ref.downloadURL { url, _ in
                    Task { @MainActor in
                        self.commitUpdate(imageUrl: url?.absoluteString ?? self.formViewModel.imageUrl, completion: completion)
                    }
                }
            }
        } else {
            commitUpdate(imageUrl: formViewModel.imageUrl, completion: completion)
        }
    }
    
    private func commitUpdate(imageUrl: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let updateData: [String: Any] = [
            "title": formViewModel.title,
            "subtitle": formViewModel.subtitle,
            "bodyText": formViewModel.bodyText,
            "linkUrl": formViewModel.linkUrl,
            "imageUrl": imageUrl
        ]
        
        db.collection("news").document(newsId).updateData(updateData) { [weak self] error in
            guard let self = self else { return }
            Task { @MainActor in
                self.isSaving = false
                completion(error == nil)
            }
        }
    }
}
