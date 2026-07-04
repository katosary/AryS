//
//  CoffeeLogViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//


import Observation
import SwiftUI
import PhotosUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

@Observable
class CoffeeLogViewModel {
    var logs: [Log] = []
    var shopName: String = ""
    var countryName: String = ""
    var isShowingCountryPicker: Bool = false
    // 1. 型定義だけしておき、初期値は代入しない
    private var db: Firestore
    
    init() {
        self.db = Firestore.firestore()
        fetchLogs()
    }
    
    let regions = [
        "中南米": ["ブラジル", "コロンビア", "ホンジュラス", "グアテマラ", "ペルー", "メキシコ", "ニカラグア", "コスタリカ", "エルサルバドル", "パナマ", "ボリビア", "エクアドル", "ジャマイカ", "キューバ", "ドミニカ共和国"],
        "アフリカ": ["エチオピア", "ケニア", "タンザニア", "ウガンダ", "ルワンダ", "ブルンジ", "コートジボワール", "コンゴ民主共和国", "カメルーン", "マラウイ", "ザンビア", "ジンバブエ"],
        "中東": ["イエメン", "サウジアラビア"],
        "アジア": ["ベトナム", "インドネシア", "インド", "ラオス", "タイ", "ミャンマー", "東ティモール", "フィリピン", "中国（雲南省）"],
        "その他（オセアニア・北米・島嶼部）": ["パプアニューギニア", "オーストラリア", "アメリカ合衆国（ハワイ・プエルトリコ）", "ニューカレドニア", "セントヘレナ島"]
    ]
    
    let regionOrder = ["中南米", "アフリカ", "中東", "アジア", "その他（オセアニア・北米・島嶼部）"]
    
    var farmName: String = ""
    var isShowingRoastPicker: Bool = false
    let roastLevels = [
        "ライトロースト", "シナモンロースト",
        "ミディアムロースト", "ハイロースト",
        "シティロースト", "フルシティロースト",
        "フレンチロースト", "イタリアンロースト"
    ]
    var roastLevel: String = ""
    var inputcoffee: String = ""
    var inputcontent: String = ""
    var iswritingsheet = false
    var aromarating: Int = 0
    var aromaComment: String = ""
    var bitternessrating1: Int = 0
    var acidityrating1: Int = 0
    var bodyrating1: Int = 0
    var bitternessrating2: Int = 0
    var acidityrating2: Int = 0
    var bodyrating2: Int = 0
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    var selectedPost: Log?
    var selectedTab: Int = 0
    
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    
    var currentOffsetX: CGFloat = 0
    var currentOffsetY: CGFloat = 0
    var tagX: CGFloat = 0
    var tagY: CGFloat = 0
    
    func updateCurrentPosition(offset: CGSize) {
        self.currentOffsetX = offset.width
        self.currentOffsetY = offset.height
    }
    
    var averagebitternessrating: Double {
        return Double(bitternessrating1 + bitternessrating2) / 2.0
    }

    var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            Task {
                await loadImages()
            }
        }
    }
    var logImages: [UIImage] = []
    
    // ViewModel内のプロパティ定義
    var user: User = User(
        userNo: 1,
        userName: "",
        selfIntroduction: "",
        userAge: 0,
        birthPlace: "",
        favoriteCoffee: "",
        probitter: 0,
        proacidity: 0,
        probody: 0,
        proaroma: 0,
        proflavor: ""
    )
    
    func addLog(currentUser: User) { // 引数 currentUser は不要になるため後で消せます
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 💡 user: currentUser を削除し、userId だけを渡す
        let newLog = Log(
            userId: uid,
            // user: currentUser, // 削除
            shopName: shopName,
            countryName: countryName,
            farmName: farmName,
            roastLevel: roastLevel,
            aromarating: aromarating,
            aromaComment: aromaComment,
            bitternessrating1: bitternessrating1,
            acidityrating1: acidityrating1,
            bodyrating1: bodyrating1,
            bitternessrating2: bitternessrating2,
            acidityrating2: acidityrating2,
            bodyrating2: bodyrating2,
            createdAt: Date(),
            tagX: currentOffsetX,
            tagY: currentOffsetY
        )
        
        // 以下、Firestoreへの保存処理はそのまま
        do {
            _ = try db.collection("posts").addDocument(from: newLog)
            clearFormFields()
        } catch {
            print("❌ 保存失敗: \(error.localizedDescription)")
        }
    }
    
    func createPreviewLog() -> Log? {
        guard let originalImage = logImages.first else { return nil }
        
        let containerSize = CGSize(width: 300, height: 400)
        let croppedImage = cropImage(image: originalImage, scale: scale, offset: offset, containerSize: containerSize)
        
        // 初期化を分割して、エラーの場所を特定しやすくする
        var log = Log(
            userId: Auth.auth().currentUser?.uid ?? "",
            shopName: shopName,
            countryName: countryName,
            farmName: farmName,
            roastLevel: roastLevel,
            aromarating: aromarating,
            aromaComment: aromaComment,
            bitternessrating1: bitternessrating1,
            acidityrating1: acidityrating1,
            bodyrating1: bodyrating1,
            bitternessrating2: bitternessrating2,
            acidityrating2: acidityrating2,
            bodyrating2: bodyrating2,
            createdAt: Date(), // Date() は関数呼び出しなので問題なし
            tagX: currentOffsetX,
            tagY: currentOffsetY
        )
        
        log.previewImage = croppedImage
        return log
    }
    
    func cropImage(image: UIImage, scale: CGFloat, offset: CGSize, containerSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: containerSize)
        
        return renderer.image { context in
            // 1. 画像の表示サイズを計算
            // 元のアスペクト比を保ったまま、枠に対して拡大・縮小する
            let aspectRatio = image.size.width / image.size.height
            let targetWidth: CGFloat
            let targetHeight: CGFloat
            
            if aspectRatio > (containerSize.width / containerSize.height) {
                targetHeight = containerSize.height * scale
                targetWidth = targetHeight * aspectRatio
            } else {
                targetWidth = containerSize.width * scale
                targetHeight = targetWidth / aspectRatio
            }
            
            // 2. 中央揃え + オフセット
            let x = (containerSize.width - targetWidth) / 2 + offset.width
            let y = (containerSize.height - targetHeight) / 2 + offset.height
            
            // 3. 描画
            image.draw(in: CGRect(x: x, y: y, width: targetWidth, height: targetHeight))
        }
    }
    
    func resetImageAdjustment() {
            scale = 1.0
            offset = .zero
        }
    
    func getFinalCroppedImage() -> UIImage? {
        guard let originalImage = logImages.first else { return nil }
        let containerSize = CGSize(width: 300, height: 400)
        return cropImage(image: originalImage, scale: scale, offset: offset, containerSize: containerSize)
    }
    
    func uploadAndSaveLog(currentUser: User, completion: @escaping (Bool) -> Void) {
        guard let originalImage = logImages.first else {
            saveLogToFirestore(currentUser: currentUser, imageUrl: nil, completion: completion)
            return
        }
        
        let containerSize = CGSize(width: 300, height: 400)
        
        // 3. 💡 cropImage を使って切り抜いた画像を生成
        guard let croppedImage = cropImage(image: originalImage, scale: scale, offset: offset, containerSize: containerSize),
              let imageData = croppedImage.jpegData(compressionQuality: 0.7) else {
            print("❌ 画像の切り抜きまたは変換に失敗しました")
            completion(false)
            return
        }
        
        // 4. 以降は同じ（切り抜いた imageData をアップロード）
        let filename = NSUUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("post_images").child(filename)
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("❌ アップロード失敗: \(error)")
                completion(false)
                return
            }
            storageRef.downloadURL { url, error in
                if let url = url {
                    self.saveLogToFirestore(currentUser: currentUser, imageUrl: url.absoluteString, completion: completion)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    // 既存の addLog の中身を少し改造した保存用関数
    func saveLogToFirestore(currentUser: User, imageUrl: String?, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ ユーザーがログインしていません")
            completion(false)
            return
        }
        
        // 既存のすべてのプロパティを渡して初期化
        // 💡 ここから user: currentUser を削除しました
        var newLog = Log(
            userId: uid,
            shopName: shopName,
            countryName: countryName,
            farmName: farmName,
            roastLevel: roastLevel,
            aromarating: aromarating,
            aromaComment: aromaComment,
            bitternessrating1: bitternessrating1,
            acidityrating1: acidityrating1,
            bodyrating1: bodyrating1,
            bitternessrating2: bitternessrating2,
            acidityrating2: acidityrating2,
            bodyrating2: bodyrating2,
            createdAt: Date(),
            tagX: currentOffsetX,
            tagY: currentOffsetY
        )
        
        // 画像URLをセット
        newLog.imageUrl = imageUrl
        
        do {
            _ = try db.collection("posts").addDocument(from: newLog)
            print("🎉 成功")
            completion(true) // 成功
        } catch {
            print("❌ 保存失敗: \(error)")
            completion(false) // 失敗
        }
    }
    
    // フォームを空にする処理をメソッド化しました
    private func clearFormFields() {
        shopName = ""; countryName = ""; farmName = ""; roastLevel = ""
        aromarating = 0; aromaComment = ""; bitternessrating1 = 0
        acidityrating1 = 0; bodyrating1 = 0; bitternessrating2 = 0
        acidityrating2 = 0; bodyrating2 = 0; logImages = []
        selectedItems = []; currentOffsetX = 0; currentOffsetY = 0
    }
    
    func updateProfileImage(image: UIImage, userId: String) async throws {
        // 1. Storageへのパスを作成（例: users/userId/profile.jpg）
        let storageRef = Storage.storage().reference().child("profileImages/\(userId).jpg")
        
        // 2. UIImage を Data に変換してアップロード
        if let data = image.jpegData(compressionQuality: 0.8) {
            _ = try await storageRef.putDataAsync(data)
            
            // 3. 公開URLを取得
            let url = try await storageRef.downloadURL()
            
            // 4. Firestoreのユーザー情報を更新
            try await db.collection("users").document(userId).updateData([
                "profileImageUrl": url.absoluteString
            ])
        }
    }
    

    func fetchUser(userId: String) async throws -> User {
        // userId が空文字列だと document() で不正な参照になる可能性がある
        guard !userId.isEmpty else {
            throw NSError(domain: "InvalidID", code: -1, userInfo: nil)
        }
        
        return try await db.collection("users").document(userId).getDocument(as: User.self)
    }
    
    func fetchLogs() {
        print("🚀 fetchLogs が呼ばれました！")
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ ログインしていないため、自分の投稿を読み込めません")
            return
        }
        
        db.collection("posts")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ データ取得エラー: \(error)")
                    return
                }
                Task { @MainActor in
                    guard let documents = snapshot?.documents else { return }
                    
                    self?.logs = documents.compactMap { document in
                        do {
                            return try document.data(as: Log.self)
                        } catch {
                            print("❌ デコードエラー: \(error)")
                            print("❌ 内容: \(document.data())")
                            return nil
                        }
                    }
                    
                    print("✅ 自分の投稿を \(self?.logs.count ?? 0) 件取得しました")
                }
            }
    }
    
    func startObservingUser(uid: String) {
        db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let data = try? snapshot?.data(as: User.self) else { return }
                self?.user = data // ユーザー情報を最新に保つ
            }
    }
    
    func updateLogPosition(id: String, offset: CGSize) {
        if let index = logs.firstIndex(where: { $0.id == id }) {
            logs[index].tagX = offset.width
            logs[index].tagY = offset.height
        }
    }
    
    func deleteLog(targetPost: Log) {
        logs.removeAll { $0.id == targetPost.id }
    }
    
    var textOffset: CGSize = .zero
    
    func synchronizeMyProfile(with updatedUser: User) {
        for index in 0..<logs.count {
            if logs[index].userId == String(updatedUser.userNo) {
            }
        }
    }
    
    @MainActor
    private func loadImages() async {
        var loadedImages: [UIImage] = []
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                loadedImages.append(uiImage)
            }
        }
        self.logImages = loadedImages
    }
}
