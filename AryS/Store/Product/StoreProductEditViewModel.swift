import SwiftUI
import Observation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@Observable
class StoreProductEditViewModel {
    var product: Product
    var formViewModel: StoreProductFormViewModel
    var isSaving = false
    
    init(product: Product) {
        self.product = product
        self.formViewModel = StoreProductFormViewModel(product: product)
        
        self.formViewModel.isBlend = product.isBlend
        if product.isBlend {
            self.formViewModel.blendName = product.productName
            let countries = product.countryName.components(separatedBy: ", ")
            if countries.indices.contains(0) { self.formViewModel.blendCountry1 = countries[0] }
            if countries.indices.contains(1) { self.formViewModel.blendCountry2 = countries[1] }
            if countries.indices.contains(2) { self.formViewModel.blendCountry3 = countries[2] }
        } else {
            self.formViewModel.productName = product.productName
            self.formViewModel.countryName = product.countryName
            self.formViewModel.farmName = product.farmName ?? ""
            self.formViewModel.grade = product.grade ?? ""
            self.formViewModel.roastLevel = product.roastLevel
        }
        
        self.formViewModel.priceText = String(product.price)
        self.formViewModel.greenBeanText = "\(product.greenBeanCost)"
        self.formViewModel.packagingText = "\(product.packagingCost)"
        self.formViewModel.shippingText = "\(product.shippingCost)"
        self.formViewModel.descriptionText = product.description
        
        // --- 既存の画像URLがあればUIImageに変換してフォーム用ViewModelにセット ---
        if !product.imageUrl.isEmpty, let url = URL(string: product.imageUrl) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            self.formViewModel.productImages = [image]
                        }
                    }
                } catch {
                    print("編集画面用画像のロードに失敗しました: \(error)")
                }
            }
        }
    }
    
    func updateProduct(completion: @escaping (Bool) -> Void) {
        guard let productId = product.id else {
            completion(false)
            return
        }
        isSaving = true
        
        let images = formViewModel.productImages
        if let image = images.first, let imageData = image.jpegData(compressionQuality: 0.7) {
            let filename = NSUUID().uuidString + ".jpg"
            let ref = Storage.storage().reference().child("product_images").child(filename)
            
            ref.putData(imageData, metadata: nil) { _, error in
                if error != nil {
                    Task { @MainActor in self.isSaving = false }
                    completion(false)
                    return
                }
                ref.downloadURL { url, _ in
                    Task { @MainActor in
                        self.saveToFirestore(imageUrl: url?.absoluteString, productId: productId, completion: completion)
                    }
                }
            }
        } else {
            saveToFirestore(imageUrl: product.imageUrl, productId: productId, completion: completion)
        }
    }
    
    private func saveToFirestore(imageUrl: String?, productId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let isBlend = formViewModel.isBlend
        
        let finalCountryName: String
        if isBlend {
            let countries = [formViewModel.blendCountry1, formViewModel.blendCountry2, formViewModel.blendCountry3].filter { !$0.isEmpty }
            finalCountryName = countries.joined(separator: ", ")
        } else {
            finalCountryName = formViewModel.countryName
        }
        
        let updateData: [String: Any] = [
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
            "imageUrl": imageUrl ?? ""
        ]
        
        db.collection("products").document(productId).updateData(updateData) { error in
            self.isSaving = false
            if let error = error {
                print("商品更新失敗: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
