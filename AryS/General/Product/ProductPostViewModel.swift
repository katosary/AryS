//
//  ProductPostViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI
import Observation

@Observable
@MainActor
class ProductPostViewModel {
    var productImage: UIImage? = nil
    var isLoadingImage = false
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        isLoadingImage = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    self.productImage = image
                }
            } catch {
                print("Failed to load product detail image: \(error)")
            }
            self.isLoadingImage = false
        }
    }
}
