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
    @State private var isMenuPresented = false
    
    // 💡 親側では「背景をぼかす・縮めるため」のフラグだけを残す
    @State private var isDetailShowing = false
    
    // --- 【設定値】サイズ・デザイン ---
    let coverHeight: CGFloat = 250
    let profileSize: CGFloat = 100
    let overlapAmount: CGFloat = 0.6
    let profileBorderColor: Color = .white
    
    var body: some View {
        GeometryReader { outerGeometry in
            let totalWidth = outerGeometry.size.width
            let totalHeight = outerGeometry.size.height
            
            ZStack {
                // ==========================================
                // レイヤー 1: メインコンテンツ
                // ==========================================
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 0) {
                            // --- 1. 上部：画像重なりエリア ---
                            ZStack(alignment: .bottom) {
                                Color.gray.opacity(0.5)
                                    .frame(height: coverHeight)
                                VStack {
                                    Text("自分が投稿したポストの中でいちばんのお気に入りを選べるボタンを作り、\nそれをここに表示する")
                                    Spacer()
                                }
                                
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
                                .overlay(Circle().stroke(profileBorderColor, lineWidth: 3))
                                .offset(y: profileSize * overlapAmount)
                            }
                            .padding(.bottom, profileSize * overlapAmount + 10)
                            
                            // --- 3. ユーザー名 ＆ 自己紹介 ---
                            VStack(spacing: 8) {
                                Text(profileViewModel.user.userName).font(.title2).bold()
                                Text(profileViewModel.user.selfIntroduction)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 10)
                            
                            // --- 4. タブ切り替え ---
                            Picker("", selection: $profileSelection) {
                                Text("Post").tag(0)
                                Text("Favorite Coffee").tag(1)
                                Text("Favorite Tool").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            
                            // --- 5. コンテンツエリア ---
                            switch profileSelection {
                            case 0:
                                // 💡 引数にサイズとBindingフラグを渡すだけ。シートのロジックは子に隠蔽されました！
                                PostContentView(
                                    profileViewModel: profileViewModel,
                                    totalWidth: totalWidth,
                                    totalHeight: totalHeight,
                                    isDetailShowing: $isDetailShowing
                                )
                            case 1:
                                MyProfileContentView(profileViewModel: profileViewModel)
                            case 2:
                                FavoriteToolContentView(profileViewModel: profileViewModel)
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .navigationTitle("プロフィール")
                }
                .customPullToRefresh {
                    try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                }
                // 💡 子ビューのシートが開くと、ここが連動して動きます
                .scaleEffect(isDetailShowing ? 0.93 : 1.0)
                .blur(radius: isDetailShowing ? 8 : 0)
                .disabled(isDetailShowing)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: isDetailShowing)
    }
}

struct PostContentView: View {
    @Environment(ViewModel.self) var viewModel
    var profileViewModel: ProfileViewModel
    let totalWidth: CGFloat
    let totalHeight: CGFloat
    
    @Binding var isDetailShowing: Bool
    @State private var selectedLog: Log? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(spacing: 16) {
                ForEach(viewModel.logs) { log in
                    PostCardView(log: log, isEditable: false)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            // 💡 確実にアニメーションを効かせて選択
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                                selectedLog = log
                                isDetailShowing = true
                            }
                        }
                }
            }
        }
        // 💡 ここから修正：ZStackの条件分岐とアニメーションを最適化
        .overlay(
            ZStack(alignment: .bottom) { // 下詰めに強制する
                if isDetailShowing, let log = selectedLog {
                    
                    // ① 背後の暗いマスク（これ自体は画面全体を覆う）
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                isDetailShowing = false
                            }
                        }
                        .transition(.opacity) // マスクはフェードイン/アウト
                    
                    // ② 下からせり出すハーフシート本体
                    VStack(spacing: 0) {
                        // ツマミ（インジケーター）
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(.gray.opacity(0.4))
                            .padding(.top, 12)
                            .padding(.bottom, 10)
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                // 📸 ① シートの中に綺麗に収まる縮小画像
                                ZStack {
                                    if !log.logImages.isEmpty, let firstImage = log.logImages.first {
                                        Image(uiImage: firstImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        ZStack {
                                            Color(.systemGray5)
                                            VStack(spacing: 8) {
                                                Image(systemName: "photo").font(.title)
                                                Text("No Image").font(.caption)
                                            }
                                            .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .frame(width: totalWidth * 0.85, height: totalWidth * 0.85 * 3/4)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                                .padding(.horizontal, 24)
                                
                                // 📝 ② ユーザー情報・テキスト・評価
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(spacing: 12) {
                                        if let uiImage = profileViewModel.profileImage {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 36, height: 36)
                                                .clipShape(Circle())
                                        }
                                        Text(profileViewModel.user.userName).font(.headline)
                                    }
                                    
                                    Text("いざって時の知識、どれくらい知ってる？🥺\n\n① ツナ缶でランプになる\n② カップ麺は水でも食べられる\n③ 泥水やお風呂の残り湯も飲み水に変える浄水器")
                                        .font(.body)
                                    
                                    Divider()
                                    
                                    // 評価パラメーター
                                    VStack(alignment: .leading, spacing: 12) {
                                        let avgBitterness = Double(log.bitternessrating1 + log.bitternessrating2) / 2.0
                                        Text("Bitterness: \(String(format: "%.1f", avgBitterness))").bold()
                                        RatingView(rating: avgBitterness, maxRating: 5)
                                        
                                        let avgAcidity = Double(log.acidityrating1 + log.acidityrating2) / 2.0
                                        Text("Acidity: \(String(format: "%.1f", avgAcidity))").bold()
                                        RatingView(rating: avgAcidity, maxRating: 5)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 30)
                            }
                        }
                    }
                    .frame(width: totalWidth, height: totalHeight * 0.65) // 確実に高さを固定
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
                    .transition(.move(edge: .bottom)) // 💡これが連動して下からシャッと出るようになります
                }
            }
            // 💡 画面全体に広げて、セーフエリアを無視させる
            .frame(width: totalWidth, height: totalHeight)
            .ignoresSafeArea()
        )
    }
}

// --- 1. コーヒーの好みカード ---
struct MyProfileContentView: View {
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // --- 1. お気に入りのコーヒー（国名） ---
            HStack(alignment: .top) {
                Text("国")
                    .font(.subheadline)
                    .bold() // 💡 存在感を強く
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading) // 💡 50に縮小
                
                Text(profileViewModel.user.favoriteCoffee.isEmpty ? "未登録" : profileViewModel.user.favoriteCoffee)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .bold()
                Spacer()
            }
            
            Divider()
            
            // --- 2. 味のパラメーター（4項目） ---
            VStack(spacing: 16) { // 縦の間隔を少し広げてゆったり
                parameterRow(label: "苦味", rating: profileViewModel.user.probitter)
                parameterRow(label: "酸味", rating: profileViewModel.user.proacidity)
                parameterRow(label: "コク", rating: profileViewModel.user.probody)
                parameterRow(label: "香り", rating: profileViewModel.user.proaroma)
            }
            
            Divider()
            
            // --- 3. フレーバー ---
            HStack(alignment: .top) {
                Text("フレーバー")
                    .font(.subheadline)
                    .bold() // 💡 存在感を強く
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading) // ここだけ文字数に合わせて80に
                
                Text(profileViewModel.user.proflavor.isEmpty ? "未登録" : profileViewModel.user.proflavor)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .bold()
                Spacer()
            }
        }
        .padding(.horizontal, 12) // 💡 カードの内側の左右余白を少しタイトに
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity) // 💡 横幅いっぱいに広げる
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(15)
    }
    
    @ViewBuilder
    private func parameterRow(label: String, rating: Int) -> some View { // 👈 ここを Double に変える
        HStack(spacing: 15) {
            Text(label)
                .font(.subheadline)
                .bold()
                .foregroundColor(.primary)
                .frame(width: 45, alignment: .leading)
            
            // 型が Double になればそのまま渡せます
            RatingView(rating: Double(rating), maxRating: profileViewModel.maxRating)
        }
        .padding(.trailing, 5)
    }
}

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
    let rating: Double // 👈 Int から Double に変更
    let maxRating: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Text("◀ 弱い")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
            
            Spacer()
            
            // --- 小数対応の星描画エリア ---
            ZStack(alignment: .leading) {
                // 下地：グレーの星（5つ）
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(.systemGray4))
                    }
                }
                
                // 上書き：オレンジの星（5つ）を、ratingの数値分だけマスクして表示
                HStack(spacing: 4) {
                    ForEach(0..<maxRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    }
                }
                .mask(
                    GeometryReader { geometry in
                        Rectangle()
                        // rating が 2.5 なら、2.5 / 5.0 = 50% の横幅だけオレンジにする
                            .frame(width: geometry.size.width * CGFloat(rating / Double(maxRating)))
                    }
                )
            }
            
            Spacer()
            
            Text("強い ▶")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}


// --- 2. お気に入りの道具カード ---
struct FavoriteToolContentView: View {
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            
            if hasDripTools {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "ドリップ用品")
                    displayRow(label: "ドリッパー", value: profileViewModel.dripper)
                    displayRow(label: "ペーパー", value: profileViewModel.paperFilter)
                    displayRow(label: "ケトル", value: profileViewModel.kettle)
                    displayRow(label: "サーバー", value: profileViewModel.server)
                    displayRow(label: "スケール", value: profileViewModel.scale)
                }
            }
            
            if hasGrinderTools {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "粉砕器具")
                    displayRow(label: "ミル", value: profileViewModel.mill)
                    displayRow(label: "グラインダー", value: profileViewModel.grinder)
                }
            }
            
            if hasOtherTools {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "その他")
                    displayRow(label: "エスプレッソ", value: profileViewModel.espressoMachine)
                    displayRow(label: "プレス", value: profileViewModel.frenchPress)
                }
            }
            
            if !hasDripTools && !hasGrinderTools && !hasOtherTools {
                Text("お気に入りの道具がまだ登録されていません。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20) // 💡内側の余白を統一
        .frame(maxWidth: .infinity) // 💡横幅いっぱいに広げる
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(15)
    }
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .padding(.top, 5)
    }
    
    @ViewBuilder
    private func displayRow(label: String, value: String) -> some View {
        if !value.isEmpty {
            HStack(alignment: .top) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 110, alignment: .leading) // 💡110で統一
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .bold()
                Spacer()
            }
            Divider()
        }
    }
    
    private var hasDripTools: Bool { !profileViewModel.dripper.isEmpty || !profileViewModel.paperFilter.isEmpty || !profileViewModel.kettle.isEmpty || !profileViewModel.server.isEmpty || !profileViewModel.scale.isEmpty }
    private var hasGrinderTools: Bool { !profileViewModel.mill.isEmpty || !profileViewModel.grinder.isEmpty }
    private var hasOtherTools: Bool { !profileViewModel.espressoMachine.isEmpty || !profileViewModel.frenchPress.isEmpty }
}


struct ProfileMenuView: View {
    @Environment(\.dismiss) var dismiss // 画面を閉じるための環境変数
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // 1. プロフィール編集への導線
                    Button {
                        dismiss() // メニューを閉じてからシートを開く、または直接遷移
                        profileViewModel.isProfileEditSheet = true
                    } label: {
                        Label("プロフィールを編集", systemImage: "pencil")
                            .foregroundColor(.primary)
                    }
                    
                    // 2. ポストを投稿
                    Button {
                        dismiss()
                    } label: {
                        Label("お知らせ", systemImage: "list.clipboard")
                            .foregroundColor(.primary)
                    }
                }
                
                Section("設定とプライバシー") {
                    NavigationLink {
                        Text("アカウント設定画面（開発中）")
                    } label: {
                        Label("アカウント", systemImage: "person.crop.circle")
                    }
                    
                    NavigationLink {
                        Text("通知設定画面（開発中）")
                    } label: {
                        Label("通知", systemImage: "bell")
                    }
                }
            }
            .navigationTitle("設定とアクティビティ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}



#Preview {
    // 1. プレビュー用のダミーデータ（不足していた引数を追加）
    let dummyUser = User(
        userNo: 1,
        userName: "コーヒー大好きさん",
        selfIntroduction: "毎日3杯は必ずコーヒーを淹れて飲みます。最近はエチオピアにハマっています！",
        userAge: 25,              // 追加：年齢（数値）
        birthPlace: "東京",        // 追加：出身地（文字列）
        favoriteCoffee: "エチオピア イルガチェフェ",
        profileImage: nil,
        probitter: 2,
        proacidity: 5,
        probody: 3,
        proaroma: 4,
        proflavor: "ベリー系"     // 追加：フレーバー（文字列）
    )
    
    let dummyLog = Log(
        user: dummyUser,
        shopName: "Blue Bottle Coffee",
        countryName: "Ethiopia",
        farmName: "Yirgacheffe Clean",
        roastLevel: "Light",
        aromarating: 4,
        aromaComment: "ジャスミンのような華やかな香り",
        bitternessrating1: 2,
        acidityrating1: 4,
        bodyrating1: 3,
        bitternessrating2: 2,
        acidityrating2: 5,
        bodyrating2: 3,
        createdAt: Date(),
        logImages: [],
        textOffset: .zero,  // 新しく追加されたプロパティ（型がCGSizeやString等なら適宜変更してください）
        tagX: 0,
        tagY: 0
    )
    
    let mockViewModel = ViewModel()
    mockViewModel.logs = [dummyLog]
    
    let mockProfileViewModel = ProfileViewModel()
    mockProfileViewModel.user = dummyUser
    mockProfileViewModel.maxRating = 5
    
    return ProfileView(viewModel: mockViewModel, profileViewModel: mockProfileViewModel)
        .environment(mockViewModel)
        .environment(mockProfileViewModel)
}
