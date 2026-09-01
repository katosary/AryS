//
//  CoffeeLogViewModel.swift
//  snsmvvm
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Observable
@MainActor
class CoffeeLogViewModel {
    var log: Log
    var author: User?
    var shouldNavigateToProfile: Bool = false
    var targetUserForProfile: User?
    
    // --- 画像保持用プロパティ ---
    var remoteImage: UIImage? = nil
    var remoteAuthorImage: UIImage? = nil
    
    private let db = Firestore.firestore()
    
    init(log: Log, author: User? = nil) {
        self.log = log
        self.author = author
        loadImages() // 初期化時に画像をロード
    }
    
    /// 💡 親から新しいログデータを受け取って即時反映するためのメソッド
    func updateLog(_ newLog: Log) {
        self.log = newLog
        loadImages()
    }
    
    /// 💡 著者情報が更新されたときにアイコン画像を再ロードするメソッド
    func updateAuthor(_ newAuthor: User?) {
        self.author = newAuthor
        loadImages()
    }
    
    // --- 投稿画像と著者アイコンを非同期で取得 ---
    private func loadImages() {
        // 1. 投稿画像のロード
        if let preview = log.previewImage {
            self.remoteImage = preview
        } else if let urlString = log.imageUrl, let url = URL(string: urlString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run { self.remoteImage = image }
                    }
                } catch {
                    print("⚠️ 投稿画像取得エラー: \(error)")
                }
            }
        }
         
        // 2. 著者プロフィール画像のロード
        let targetProfileImageUrl = author?.profileImageUrl
        
        if let urlString = targetProfileImageUrl, !urlString.isEmpty, let url = URL(string: urlString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run { self.remoteAuthorImage = image }
                    }
                } catch {
                    print("⚠️ 著者アイコン画像取得エラー: \(error)")
                }
            }
        } else {
            // 画像URLがない場合はクリアする
            self.remoteAuthorImage = nil
        }
    }
    
    private var currentUid: String? {
        Auth.auth().currentUser?.uid
    }
    
    var isMyPost: Bool {
        guard let currentUid else { return false }
        return log.userId == currentUid
    }
    
    var isLikedByMe: Bool {
        guard let currentUid else { return false }
        return log.likedUserIds.contains(currentUid)
    }
    
    func toggleLike() {
        guard let currentUid, let logId = log.id else { return }
         
        let previousState = isLikedByMe
        let previousCount = log.likesCount
         
        if previousState {
            log.likedUserIds.removeAll { $0 == currentUid }
            log.likesCount = max(0, log.likesCount - 1)
        } else {
            log.likedUserIds.append(currentUid)
            log.likesCount += 1
        }
         
        let postRef = db.collection("posts").document(logId)
         
        Task {
            do {
                if previousState {
                    try await postRef.updateData([
                        "likedUserIds": FieldValue.arrayRemove([currentUid]),
                        "likesCount": FieldValue.increment(Int64(-1))
                    ])
                } else {
                    try await postRef.updateData([
                        "likedUserIds": FieldValue.arrayUnion([currentUid]),
                        "likesCount": FieldValue.increment(Int64(1))
                    ])
                }
            } catch {
                if previousState {
                    self.log.likedUserIds.append(currentUid)
                    self.log.likesCount = previousCount
                } else {
                    self.log.likedUserIds.removeAll { $0 == currentUid }
                    self.log.likesCount = previousCount
                }
                print("Failed to toggle like: \(error.localizedDescription)")
            }
        }
    }
    
    func toggleSave(bookmarkManager: BookmarkManager) {
        guard let logId = log.id else { return }
        bookmarkManager.toggleSave(for: logId)
    }
    
    func onTapProfile(currentProfileUser: User? = nil) {
        targetUserForProfile = isMyPost ? currentProfileUser : author
        shouldNavigateToProfile = true
    }
    
    func deletePost() {
        guard let logId = log.id else { return }
         
        Task {
            do {
                try await db.collection("posts").document(logId).delete()
                print("投稿を削除しました: \(logId)")
            } catch {
                print("Failed to delete post: \(error.localizedDescription)")
            }
        }
    }
}
