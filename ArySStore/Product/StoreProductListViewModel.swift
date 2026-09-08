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
    var isLoading = true
    
    private var listenerRegistration: ListenerRegistration?

    func fetchProducts() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.isLoading = false
            return
        }
        
        listenerRegistration = Firestore.firestore().collection("products")
            .whereField("userId", isEqualTo: uid)
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
                
                self.products = documents.compactMap { doc -> Product? in
                    try? doc.data(as: Product.self)
                }
            }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
