//
//  PostViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

//ViewModel
import Observation
import SwiftUI
import PhotosUI
import FirebaseCore       // Firebase自体の初期化（configure）に必要
import FirebaseFirestore  // Firestoreのデータベース操作に必要
import FirebaseStorage
import FirebaseAuth

@Observable
class ViewModel {
    var logs: [Log] = []
    var shopName: String = ""
    var countryName: String = ""
    var isShowingCountryPicker: Bool = false
    // 1. 型定義だけしておき、初期値は代入しない
    private var db: Firestore
    
    init() {
        // 2. initの中で初期化する
        // これにより、アプリが起動してFirebaseApp.configure()が呼ばれた後で
        // ViewModelが作られるため、クラッシュしなくなります
        self.db = Firestore.firestore()
        
        // 3. 必要であればここでフェッチを開始する
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
    var editingUser: String = ""
    var editingCoffee: String = ""
    var editingFavoCoffee: String = ""
    var editingContent: String = ""
    var iswritingsheet = false
    var isEditSheet: Bool = false
    var aromarating: Int = 0
    var aromaComment: String = ""
    var bitternessrating1: Int = 0
    var acidityrating1: Int = 0
    var bodyrating1: Int = 0
    var bitternessrating2: Int = 0
    var acidityrating2: Int = 0
    var bodyrating2: Int = 0
    var maxRating = 5
    var editingRating: Int = 0
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    var selectedPost: Log?
    var selectedTab: Int = 0
    
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
    
    // 💡 1枚専用なので、selectedItems から最初の1枚だけを処理するようにしてもOK
    var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            Task {
                await loadImages()
            }
        }
    }
    
    // 入力中のプレビュー用画像
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
    
    func uploadAndSaveLog(currentUser: User, completion: @escaping (Bool) -> Void) {
        guard let image = logImages.first,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            saveLogToFirestore(currentUser: currentUser, imageUrl: nil, completion: completion)
            return
        }
        
        let filename = NSUUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("post_images").child(filename)
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("❌ アップロード失敗: \(error)")
                completion(false) // 失敗
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
    
    // 💡 これを追加してください！
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
                
                // 💡 ここが重要：UI更新は必ずメインスレッドで行う
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
    
    func updateLog(targetPost: Log) {
        if let id = logs.firstIndex(where: { $0.id == targetPost.id }) {
            logs[id].countryName = self.editingCoffee
            logs[id].aromarating = self.editingRating
            clearEditingLog()
            self.isEditSheet = false
        }
    }
    
    func clearEditingLog() {
        self.editingCoffee = ""
        self.editingContent = ""
        self.editingRating = 0
    }
    
    func updateLogPosition(id: String, offset: CGSize) {
        // インデックスを取得し、安全に更新する
        if let index = logs.firstIndex(where: { $0.id == id }) {
            
            
            // （もし必要であれば）ここで tagX, tagY も更新する
            logs[index].tagX = offset.width
            logs[index].tagY = offset.height
        }
    }
    
    func deleteLog(targetPost: Log) {
        logs.removeAll { $0.id == targetPost.id }
    }
    
    var textOffset: CGSize = .zero
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
    
    // 💡 プロフィールが更新されたら、自分の過去の投稿データを一括更新する
    func synchronizeMyProfile(with updatedUser: User) {
        for index in 0..<logs.count {
            // 修正前: if logs[index].user.userNo == updatedUser.userNo { ... }
            
            // 修正後: userId (String) と Stringに変換した userNo を比較する
            if logs[index].userId == String(updatedUser.userNo) {
                // もし投稿の中にユーザー名などを直接保持している場合は、ここで更新します。
                // 現状 Log 構造体から user を削除済みであれば、この処理自体が不要になる可能性があります。
                // データの整合性を保つためのロジックをここに記述してください。
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
