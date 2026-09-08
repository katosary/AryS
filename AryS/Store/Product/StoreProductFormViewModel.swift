import SwiftUI
import Observation
import PhotosUI

@Observable
class StoreProductFormViewModel {
    var product: Product
    
    var isBlend: Bool = false
    
    var productName: String
    var countryName: String = ""
    var farmName: String = ""
    var grade: String = ""
    var roastLevel: String = ""
    
    var blendName: String = ""
    var blendCountry1: String = ""
    var blendCountry2: String = ""
    var blendCountry3: String = ""
    
    var priceText: String
    var greenBeanText: String
    var packagingText: String
    var shippingText: String
    var descriptionText: String
    
    var sampleImages: [String] = ["photo1", "photo2", "photo3"]
    var productImages: [UIImage] = []
    var selectedPhotoItems: [PhotosPickerItem] = [] {
        didSet { Task { await loadImages() } }
    }
    var currentIndex = 0
    var isShowingImagePicker = false
    
    var isShowingCountryPicker: Bool = false
    var activeCountryTarget: CountryTarget = .single
    var isShowingRoastPicker: Bool = false
    
    enum CountryTarget {
        case single, blend1, blend2, blend3
    }
    
    init(product: Product) {
        self.product = product
        self.productName = product.productName
        self.priceText = String(product.price)
        self.greenBeanText = String(product.greenBeanCost)
        self.packagingText = String(product.packagingCost)
        self.shippingText = String(product.shippingCost)
        self.descriptionText = product.description
    }
    
    @MainActor
    private func loadImages() async {
        productImages = []
        for item in selectedPhotoItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                productImages.append(uiImage)
            }
        }
    }
    
    func calculateCreditFee() -> Int {
        let price = Double(priceText) ?? 0.0
        return Int(price * 0.035)
    }
    
    func calculateProfit() -> Int {
        let price = Int(priceText) ?? 0
        let greenBean = Int(greenBeanText) ?? 0
        let packaging = Int(packagingText) ?? 0
        let shipping = Int(shippingText) ?? 0
        let creditFee = calculateCreditFee()
        
        return price - (greenBean + packaging + shipping + creditFee)
    }
}
