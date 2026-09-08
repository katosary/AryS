//
//  ProductListViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI
import FirebaseFirestore
import Observation

@Observable
class ProductListViewModel {
    var products: [Product] = []
    var productImages: [String: UIImage] = [:]
    var isLoading = true
    
    private var listenerRegistration: ListenerRegistration?

    func fetchProducts(for storeId: String) {
        listenerRegistration = Firestore.firestore().collection("products")
            .whereField("storeId", isEqualTo: storeId)
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
            print("Failed to load product image: \(error)")
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
