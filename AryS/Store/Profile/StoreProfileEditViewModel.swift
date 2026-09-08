//
//  StoreProfileEditViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/07.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

@MainActor
@Observable
class StoreProfileEditViewModel {
    var storeName: String
    var prefecture: String
    var roasterName: String
    var roasterBio: String
    var roastingExperience: String
    var roastingMachine: String
    var storeImageURL: String?
    var roasterImageURL: String?
    
    // 店舗写真用
    var selectedPhotoItem: PhotosPickerItem? = nil {
        didSet {
            Task { await loadImage(from: selectedPhotoItem) }
        }
    }
    var selectedImage: UIImage? = nil
    
    // 焙煎士写真用
    var selectedRoasterPhotoItem: PhotosPickerItem? = nil {
        didSet {
            Task { await loadRoasterImage(from: selectedRoasterPhotoItem) }
        }
    }
    var selectedRoasterImage: UIImage? = nil
    
    var isSaving = false
    var errorMessage: String?
    
    private var originalStore: Store?
    
    init(store: Store?) {
        self.originalStore = store
        self.storeName = store?.storeName ?? ""
        self.prefecture = store?.prefecture ?? ""
        self.roasterName = store?.roasterName ?? ""
        self.roasterBio = store?.roasterBio ?? ""
        self.roastingExperience = store?.roastingExperience ?? ""
        self.roastingMachine = store?.roastingMachine ?? ""
        self.storeImageURL = store?.storeImageURL
        self.roasterImageURL = store?.roasterImageURL
    }
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                self.selectedImage = uiImage
            }
        } catch {
            print("店舗画像の読み込みに失敗しました: \(error)")
        }
    }
    
    private func loadRoasterImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                self.selectedRoasterImage = uiImage
            }
        } catch {
            print("焙煎士画像の読み込みに失敗しました: \(error)")
        }
    }
    
    func saveStore(completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isSaving = true
        
        Task {
            do {
                var imageURL = self.storeImageURL
                var roasterURL = self.roasterImageURL
                
                if let image = selectedImage {
                    imageURL = try await uploadImageToStorage(image: image, path: "store_images/\(uid).jpg")
                }
                
                if let roasterImage = selectedRoasterImage {
                    roasterURL = try await uploadImageToStorage(image: roasterImage, path: "roaster_images/\(uid).jpg")
                }
                
                let db = Firestore.firestore()
                var updateData: [String: Any] = [
                    "storeName": storeName,
                    "prefecture": prefecture,
                    "roasterName": roasterName,
                    "roasterBio": roasterBio,
                    "roastingExperience": roastingExperience,
                    "roastingMachine": roastingMachine
                ]
                
                if let imageURL = imageURL {
                    updateData["storeImageURL"] = imageURL
                }
                if let roasterURL = roasterURL {
                    updateData["roasterImageURL"] = roasterURL
                }
                
                try await db.collection("stores").document(uid).updateData(updateData)
                
                if var currentStore = originalStore {
                    currentStore.storeName = storeName
                    currentStore.prefecture = prefecture
                    currentStore.roasterName = roasterName
                    currentStore.roasterBio = roasterBio
                    currentStore.roastingExperience = roastingExperience
                    currentStore.roastingMachine = roastingMachine
                    currentStore.storeImageURL = imageURL
                    currentStore.roasterImageURL = roasterURL
                    originalStore = currentStore
                }
                
                isSaving = false
                completion()
                
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
                print("店舗データの保存に失敗しました: \(error)")
            }
        }
    }
    
    private func uploadImageToStorage(image: UIImage, path: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "画像の変換に失敗しました"])
        }
        
        let storageRef = Storage.storage().reference().child(path)
        _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
}
