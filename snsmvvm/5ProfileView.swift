//
//  ProfileView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/22.
//

import SwiftUI

struct ProfileView: View {
    var viewModel: ViewModel
    var profileViewModel: ProfileViewModel
    @State private var profileSelection = 0
    
    // --- 【設定値】サイズ・デザイン ---
    let coverHeight: CGFloat = 250         // カバー写真の高さ
    let profileSize: CGFloat = 100         // プロフィール写真のサイズ（直径）
    let overlapAmount: CGFloat = 0.6       // プロフィール写真がカバーからはみ出る割合
    let profileBorderColor: Color = .white   // プロフィール写真の縁取りの色
    
    var body: some View {
        NavigationStack {
            // 💡 画面全体のスクロールを1つに統合
            ScrollView {
                VStack(spacing: 0) {
                    // --- 2. プロフィール編集ボタン ---
                    HStack {
                        Spacer()
                        Button {
                            profileViewModel.isProfileEditSheet = true
                        } label: {
                            Text("プロフィールを編集")
                                .font(Font.headline.bold())
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // --- 1. 上部：画像重なりエリア (カバー写真 + プロフィール写真) ---
                    ZStack(alignment: .bottom) {
                        // --- A. カバー写真 ---
                        if let uiImage = profileViewModel.favoriteCoffeeImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: coverHeight)
                                .clipped()
                        } else {
                            Color.gray.opacity(0.5)
                                .frame(height: coverHeight)
                        }
                        
                        // --- B. プロフィール写真 ---
                        Group {
                            if let uiImage = profileViewModel.profileImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray.opacity(0.6))
                                    .background(Color.white)
                            }
                        }
                        .frame(width: profileSize, height: profileSize)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(profileBorderColor, lineWidth: 3)) // 縁取りを追加
                        // 💡 半分ほど下に飛び出させるオフセット処理
                        .offset(y: profileSize * overlapAmount)
                    }
                    // 下のコンテンツがプロフィール画像と被らないように、はみ出た分の余白を確保
                    .padding(.bottom, profileSize * overlapAmount + 10)
                    
                    
                    // --- 3. ユーザー名 ＆ 自己紹介 ---
                    VStack(spacing: 8) {
                        Text(profileViewModel.user.userName)
                            .font(.title2)
                            .bold()
                        
                        Text(profileViewModel.user.selfIntroduction)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 10)
                    
                    // --- 4. タブ切り替え（Picker） ---
                    Picker("", selection: $profileSelection) {
                        Text("Post").tag(0)
                        Text("Favorite Coffee").tag(1)
                        Text("Favorite Tool").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // --- 5. コンテンツエリア（if-elseによる切り替え） ---
                    // 💡 ScrollViewの中にScrollViewを入れないため、各View内のScrollViewは排除します
                    switch profileSelection {
                    case 0:
                        PostContentView()
                    case 1:
                        MyProfileContentView(profileViewModel: profileViewModel)
                    case 2:
                        FavoriteToolContentView()
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("プロフィール")
            .sheet(isPresented: .init(
                get: { profileViewModel.isProfileEditSheet },
                set: { profileViewModel.isProfileEditSheet = $0 }
            )){
                // ⭕️ 新しく作らず、自分が持っている「本物のprofileViewModel」をそのまま渡す！
                ProfileEditView(profileViewModel: self.profileViewModel)
                    .onAppear {
                        profileViewModel.logs = viewModel.logs
                    }
            }
        }
    }
}

// 💡 各子ビューから重複する「ScrollView」を取り除き、中身だけに分離しました
struct MyProfileContentView: View {
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("お気に入りのコーヒー：")
                    .bold()
                Text(profileViewModel.user.favoriteCoffee)
            }
            
            VStack(spacing: 12) {
                RatingView(label: "苦味", rating: profileViewModel.user.probitter, maxRating: profileViewModel.maxRating)
                RatingView(label: "酸味", rating: profileViewModel.user.proacidity, maxRating: profileViewModel.maxRating)
                RatingView(label: "コク", rating: profileViewModel.user.probody, maxRating: profileViewModel.maxRating)
                RatingView(label: "香り", rating: profileViewModel.user.proaroma, maxRating: profileViewModel.maxRating)
            }
            
            HStack {
                Text("フレーバー：").bold()
                Text("アッシー")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PostContentView: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.logs) { log in
                PostCardView(log: log,isEditable: false)
            }
        }
        .padding(.vertical, 10)
    }
}

struct FavoriteToolContentView: View {
    var body: some View {
        VStack {
            Text("お気に入りの器具はまだ登録されていません")
                .foregroundColor(.secondary)
                .font(.footnote)
                .padding(.top, 40)
        }
    }
}

// --- 以下、PostCardView などのコンポーネントは元のままで綺麗に動きます ---
/// 単一のポストカード
/// 単一のポストカード
struct PostCardView: View {
    let log: Log
    @Environment(ViewModel.self) var viewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    var isEditable: Bool
    
    @State private var dragOffset: CGSize = .zero
    let profileSize: CGFloat = 40
    
    // 投稿者が自分かどうかを判定
    private var isMyPost: Bool {
        log.user.userNo == profileViewModel.user.userNo
    }
    
    // 💡 表示に使うユーザー情報を動的に切り替えるプロパティ
    private var displayUser: User {
        isMyPost ? profileViewModel.user : log.user
    }
    
    var body: some View {
        // ⚠️ bodyの直下を大きなVStackで包むことで、全体のレイアウトを縦に並べます
        VStack(spacing: 16) {
            
            // --- ① ヘッダーエリア ---
            HStack(spacing: 12) { // ユーザ情報とメニューを横並びにするためHStackがおすすめ
                // --- B. プロフィール写真 ---
                Group {
                    if let uiImage = displayUser.profileImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray.opacity(0.6))
                            .background(Color.white)
                    }
                }
                .frame(width: profileSize, height: profileSize)
                .clipShape(Circle())
//                // 画像の表示ロジック
//                if isMyPost {
//                    if let uiImage = profileViewModel.profileImage {
//                        Image(uiImage: uiImage)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: profileSize, height: profileSize)
//                            .clipShape(Circle())
//                    } else {
//                        Image(systemName: "person.crop.circle.fill")
//                            .resizable()
//                            .frame(width: profileSize, height: profileSize)
//                            .foregroundColor(.gray.opacity(0.6))
//                    }
//                } else {
//                    if let uiImage = log.logImages.first {
//                        Image(uiImage: uiImage)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: profileSize, height: profileSize)
//                            .clipShape(Circle())
//                    } else {
//                        Image(systemName: "person.crop.circle.fill")
//                            .resizable()
//                            .frame(width: profileSize, height: profileSize)
//                            .foregroundColor(.gray.opacity(0.6))
//                    }
//                }
                
                // 名前
                Text(displayUser.userName.isEmpty ? "名無しのユーザー" : displayUser.userName)
                    .font(.title2)
                    .bold()

                
                
                
                Spacer()
                
                // 日付
                Text(log.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 編集・削除メニュー
                if isMyPost {
                    Menu {
                        Button {
                            viewModel.selectedPost = log
                            viewModel.isEditSheet = true
                        } label: {
                            Label("編集", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            viewModel.deleteLog(targetPost: log)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .padding(5)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 12)
            
            // --- ② 画像・テキストオーバーレイエリア ---
            ZStack {
                if let firstImage = log.logImages.first {
                    Image(uiImage: firstImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            VStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.largeTitle)
                                Text("写真が選択されていません")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
                
                // ドラッグ可能な情報タグ
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text("Shop: \(log.shopName)")
                        Text("Origin: \(log.countryName)")
                        Text("Farm: \(log.farmName)")
                        Text("Roast: \(log.roastLevel)")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .foregroundColor(.primary)
                .offset(
                    x: isEditable ? viewModel.currentOffsetX + dragOffset.width : log.tagX,
                    y: isEditable ? viewModel.currentOffsetY + dragOffset.height : log.tagY
                )
                .gesture(
                    isEditable ?
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            viewModel.currentOffsetX += value.translation.width
                            viewModel.currentOffsetY += value.translation.height
                            dragOffset = .zero
                        }
                    : nil
                )
            }
            
            // --- ③ 評価・コメントエリア ---
            VStack(alignment: .leading, spacing: 8) {
                // Bitterness
                HStack {
                    Text("Bitterness:")
                        .frame(width: 90, alignment: .leading)
                    let avgBitterness = Double(log.bitternessrating1 + log.bitternessrating2) / 2.0
                    CustomStarRating(rating: avgBitterness)
                }
                
                // Acidity
                HStack {
                    Text("Acidity:")
                        .frame(width: 90, alignment: .leading)
                    let avgAcidity = Double(log.acidityrating1 + log.acidityrating2) / 2.0
                    CustomStarRating(rating: avgAcidity)
                }
                
                // Body
                HStack {
                    Text("Body:")
                        .frame(width: 90, alignment: .leading)
                    let avgBody = Double(log.bodyrating1 + log.bodyrating2) / 2.0
                    CustomStarRating(rating: avgBody)
                }
                
                // Aroma
                HStack {
                    Text("Aroma:")
                        .frame(width: 90, alignment: .leading)
                    CustomStarRating(rating: Double(log.aromarating))
                }
                
                if !log.aromaComment.isEmpty {
                    HStack {
                        Text("香りの種類:")
                            .foregroundColor(.secondary)
                        Text(log.aromaComment)
                    }
                    .font(.footnote)
                    .padding(.top, 4)
                }
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16) // 全体の余白
        .padding(.vertical, 12)
    } // <- body の閉じ括弧
} // <- PostCardView の閉じ括弧

// 💡 星のマスク描画部分を、すっきり共通コンポーネント化しました
struct CustomStarRating: View {
    let rating: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in Image(systemName: "star").foregroundColor(.gray.opacity(0.4)) }
            }
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in Image(systemName: "star.fill").foregroundColor(.orange) }
            }
            .mask(
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width * CGFloat(rating / 5.0))
                }
            )
        }
    }
}

struct RatingView: View {
    let label: String
    let rating: Int
    let maxRating: Int
    
    var body: some View {
        HStack {
            Text(label)
                .padding(5)
                .font(.system(size: 20)) // サイズはお好みで調整してください
            
            Text("弱い").padding(5)
            
            HStack {
                ForEach(1...maxRating, id: \.self) { number in
                    Image(systemName: "star.fill") // もしくは viewModel.image
                        .font(.system(size: 20))
                        .foregroundColor(number > rating ? .gray : .orange)
                }
            }
            
            Text("強い").padding(5)
        }
    }
}




#Preview {
    // 1. メインの ViewModel を作成し、サンプル投稿を追加
    let sharedViewModel = ViewModel()
    
    // サンプルユーザーの作成
    let sampleUser = User(
        userNo: 1,
        userName: "コーヒー愛好家",
        selfIntroduction: "毎日自宅で豆を挽いてドリップしています。\n浅煎りのエチオピアが特に好きです。",
        userAge: 21,
        birthPlace: "神奈川県",
        favoriteCoffee: "エチオピア イルガチェフェ",
        probitter: 2,
        proacidity: 5,
        probody: 3,
        proaroma: 5,
        proflavor: "アッシーフ、ベリー、ナッツ"
    )
    
    // サンプル投稿（Log）を2件ほど追加
    sharedViewModel.logs = [
        Log(
            user: sampleUser,
            shopName: "Blue Bottle Coffee",
            countryName: "Ethiopia",
            farmName: "Guji Zone",
            roastLevel: "Light",
            aromarating: 5,
            aromaComment: "ベリーのような酸味",
            bitternessrating1: 1,
            acidityrating1: 5,
            bodyrating1: 2,
            bitternessrating2: 2,
            acidityrating2: 4,
            bodyrating2: 3,
            createdAt: Date(),
            logImages: [UIImage(systemName: "bean.fill") ?? UIImage()],
            tagX: 10,
            tagY: 20
        ),
        Log(
            user: sampleUser,
            shopName: "自家焙煎所",
            countryName: "Colombia",
            farmName: "Unknown",
            roastLevel: "Medium",
            aromarating: 4,
            aromaComment: "ナッツのような香ばしさ",
            bitternessrating1: 3,
            acidityrating1: 3,
            bodyrating1: 4,
            bitternessrating2: 3,
            acidityrating2: 3,
            bodyrating2: 4,
            createdAt: Date().addingTimeInterval(-86400), // 1日前
            logImages: [UIImage(systemName: "bean.fill") ?? UIImage()],
            tagX: -30,
            tagY: -10
        )
    ]
    // ProfileView.swift の #Preview の中
    let sharedProfileViewModel = ProfileViewModel()
    sharedProfileViewModel.user = sampleUser
    // 💡 プレビュー用のダミー画像をセットしてあげる
    sharedProfileViewModel.profileImage = UIImage(systemName: "person.circle.fill")
    sharedProfileViewModel.favoriteCoffeeImage = UIImage(systemName: "photo")
    
    // 3. ProfileView 本体をプレビュー
    return ProfileView(
        viewModel: sharedViewModel,
        profileViewModel: sharedProfileViewModel
    )
}
