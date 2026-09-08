//
//  StoreNewsAddViewModel.swift
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
final class StoreNewsAddViewModel {
    var formViewModel = StoreNewsFormViewModel()
    var isSaving = false
    
    func addNews(completion: @escaping (Bool) -> Void) {
        guard let storeUid = Auth.auth().currentUser?.uid else { return }
        isSaving = true
        
        if let image = formViewModel.selectedImage, let imageData = image.jpegData(compressionQuality: 0.7) {
            let filename = NSUUID().uuidString + ".jpg"
            let ref = Storage.storage().reference().child("news_images").child(filename)
            
            ref.putData(imageData, metadata: nil) { [weak self] _, error in
                if error != nil {
                    Task { @MainActor in self?.isSaving = false }
                    completion(false)
                    return
                }
                ref.downloadURL { url, _ in
                    Task { @MainActor in
                        self?.saveToFirestore(imageUrl: url?.absoluteString ?? "", storeUid: storeUid, completion: completion)
                    }
                }
            }
        } else {
            saveToFirestore(imageUrl: "", storeUid: storeUid, completion: completion)
        }
    }
    
    private func saveToFirestore(imageUrl: String, storeUid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let newsData: [String: Any] = [
            "storeId": storeUid,
            "title": formViewModel.title,
            "subtitle": formViewModel.subtitle,
            "bodyText": formViewModel.bodyText,
            "linkUrl": formViewModel.linkUrl,
            "imageUrl": imageUrl,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("news").addDocument(data: newsData) { [weak self] error in
            Task { @MainActor in
                self?.isSaving = false
                completion(error == nil)
            }
        }
    }
}
