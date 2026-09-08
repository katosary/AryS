//
//  StoreNewsFormViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class StoreNewsFormViewModel {
    var title = ""
    var subtitle = ""
    var bodyText = ""
    var linkUrl = ""
    var imageUrl = ""
    var selectedImage: UIImage? = nil
    
    var isLoading = false
    var errorMessage = ""
    
    var isValid: Bool {
        !title.isEmpty && !bodyText.isEmpty
    }
    
    // 初期化（新規なら空、編集時は既存データをセット）
    init(title: String = "", subtitle: String = "", bodyText: String = "", linkUrl: String = "", imageUrl: String = "") {
        self.title = title
        self.subtitle = subtitle
        self.bodyText = bodyText
        self.linkUrl = linkUrl
        self.imageUrl = imageUrl
    }
}
