//
//  StoreProductListViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/07.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Observation

@Observable
class StoreProductListViewModel {
    var products: [Product] = []
    var productImages: [String: UIImage] = [:]
    var isLoading = true
    
    private var listenerRegistration: ListenerRegistration?

    func fetchProducts() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.isLoading = false
            return
        }
        
        listenerRegistration = Firestore.firestore().collection("products")
            .whereField("storeId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("商品データの取得に失敗しました: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.products = []
                    return
                }
                
                let loadedProducts = documents.compactMap { doc -> Product? in
                    try? doc.data(as: Product.self)
                }
                
                Task { @MainActor in
                    self.products = loadedProducts
                    for product in loadedProducts {
                        if let id = product.id, !product.imageUrl.isEmpty, let url = URL(string: product.imageUrl) {
                            await self.fetchImage(for: id, from: url)
                        }
                    }
                }
            }
    }
    
    private func fetchImage(for id: String, from url: URL) async {
        guard productImages[id] == nil else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                productImages[id] = image
            }
        } catch {
            print("Failed to load store product image: \(error)")
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
