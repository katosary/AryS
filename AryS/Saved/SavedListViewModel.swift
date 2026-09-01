
//
//  SavedListViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/13.
//

import Observation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Observable
class SavedListViewModel {
    var savedLogs: [Log] = []
    
    // 💡 投稿IDごとの画像を保持する辞書
    var thumbnailImages: [String: UIImage] = [:]
    
    private let db = Firestore.firestore()
         
    init() {
        // 初期化時
    }
         
    func fetchUser(userId: String) async throws -> User {
        let doc = try await db.collection("users").document(userId).getDocument()
        return try doc.data(as: User.self)
    }

    func fetchSavedPosts(with logIds: Set<String>) {
        guard !logIds.isEmpty else {
            DispatchQueue.main.async {
                self.savedLogs = []
                self.thumbnailImages.removeAll()
            }
            return
        }
             
        Task {
            var fetchedLogs: [Log] = []
            for id in logIds {
                do {
                    let doc = try await db.collection("posts").document(id).getDocument()
                    if let log = try? doc.data(as: Log.self) {
                        fetchedLogs.append(log)
                        // 💡 取得したログの画像をロード
                        fetchThumbnailImage(for: log)
                    }
                } catch {
                    print("Failed to fetch post \(id): \(error.localizedDescription)")
                }
            }
                 
            DispatchQueue.main.async {
                self.savedLogs = fetchedLogs
            }
        }
    }
    
    // 💡 画像の非同期ダウンロードとキャッシュ保持
    private func fetchThumbnailImage(for log: Log) {
        guard let logId = log.id,
              thumbnailImages[logId] == nil,
              let imageUrlString = log.imageUrl,
              let url = URL(string: imageUrlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        self.thumbnailImages[logId] = uiImage
                    }
                }
            } catch {
                print("保存済み投稿のサムネイル取得に失敗しました: \(error)")
            }
        }
    }
}
