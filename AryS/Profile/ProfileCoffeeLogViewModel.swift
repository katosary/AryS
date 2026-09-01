import Observation
import FirebaseFirestore
import FirebaseAuth
import UIKit // 追加

@Observable
class ProfileCoffeeLogViewModel {
    var logs: [Log] = []
    
    // 💡 投稿IDごとの画像を保持する辞書
    var thumbnailImages: [String: UIImage] = [:]
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func startListeningUserLogs() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        listener?.remove()
        
        listener = db.collection("posts")
            .whereField("userId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("ログの監視に失敗しました: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                self.logs = documents.compactMap { document in
                    try? document.data(as: Log.self)
                }
                
                // 💡 取得したログの画像を一括でロードする
                for log in self.logs {
                    self.fetchThumbnailImage(for: log)
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func fetchUser(userId: String) async throws -> User {
        let doc = try await Firestore.firestore().collection("users").document(userId).getDocument()
        return try doc.data(as: User.self)
    }
    
    func fetchLogs() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("posts")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ データ取得エラー: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.logs = documents.compactMap { document in
                    try? document.data(as: Log.self)
                }
                
                // 💡 取得したログの画像を一括でロードする
                for log in self.logs {
                    self.fetchThumbnailImage(for: log)
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
                print("サムネイル画像の取得に失敗しました: \(error)")
            }
        }
    }
    
    func deleteLog(targetPost: Log) {
        guard let id = targetPost.id else { return }
        Firestore.firestore().collection("posts").document(id).delete() { error in
            if let error = error {
                print("削除に失敗しました: \(error)")
            }
        }
        logs.removeAll { $0.id == id }
        if let id = targetPost.id {
            thumbnailImages.removeValue(forKey: id)
        }
    }
    
    deinit {
        stopListening()
    }
}
