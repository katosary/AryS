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
    var selectedImage: UIImage? = nil
    
    var isLoading = false
    var errorMessage = ""
    
    var isValid: Bool {
        !title.isEmpty && !bodyText.isEmpty
    }
    
    // 新規追加または編集に応じた保存処理（必要に応じてニュースIDなどを保持して拡張可能）
    func saveNews(completion: @escaping () -> Void) {
        // TODO: 実際のFirestore保存処理や更新処理をここに記述
        clearForm()
        completion()
    }
    
    func clearForm() {
        title = ""
        subtitle = ""
        bodyText = ""
        linkUrl = ""
        selectedImage = nil
    }
}
