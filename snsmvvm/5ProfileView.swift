//
//  ProfileView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/22.
//

import SwiftUI

struct ProfileView: View {
    @State private var profileSelection = 0
    var viewModel: ViewModel
    @State var profileViewModel = ProfileViewModel()
    
    // 画面の横幅を取得
    //let screenWidth = UIScreen.main.bounds.width   ←これは古い
    
    // --- 【設定値】サイズ・デザイン ---
    let coverHeight: CGFloat = 250         // カバー写真の高さ
    let profileSize: CGFloat = 100         // プロフィール写真のサイズ（直径）
    let overlapAmount: CGFloat = 0.4       // プロフィール写真がカバーに重なる割合（0.0〜1.0）
    let profileBorderColor: Color = .white   // プロフィール写真の縁取りの色
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width // ここで横幅を取得
            NavigationStack{
                ScrollView{
                    // プロフィール編集ボタン
                    HStack{
                        Spacer()
                        Button{
                            profileViewModel.isProfileEditSheet = true
                        } label: {
                            Text("プロフィールを編集")
                                .font(Font.headline.bold())
                                .padding(.vertical, 5)    // 上下の厚み（大きくしたい分だけ数値を増やす）
                                .padding(.horizontal, 10)  // 左右の幅
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                        .padding(.top, 5)
                        .padding(.trailing, 5)
                        
                    }
                    VStack {
                        
                        VStack(spacing: 0) {
                            
                            // 1. 上部：画像重なりエリア (カバー写真 + プロフィール写真)
                            ZStack(alignment: .bottom) { // 下基準で重ねる
                                
                                // --- A. カバー写真 (一番奥) ---
                                // Image(coverImageName) // 実画像を使う場合
                                if let uiImage = profileViewModel.favoriteCoffeeImage {
                                    // 画像がある場合
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()//これを入れないと、画像が元のサイズのまま表示されて枠からはみ出したり、逆に小さすぎたりします。
                                        .frame(width: screenWidth, height: coverHeight)
                                        .clipped()//指定した frame（枠）からはみ出た部分をきれいにカットしてくれます。
                                } else {
                                    // 画像がない場合（灰色の四角）
                                    Color.gray.opacity(0.5)
                                        .frame(width: screenWidth, height: coverHeight)
                                }
                                
                                
                                // .clipped() // 画像がはみ出る場合
                                
                                // --- B. プロフィール写真 (手前) ---
                                // Image(profileImageName) // 実画像を使う場合
                                if let uiImage = profileViewModel.profileImage {
                                    // ✅ 画像がある場合：丸く切り抜いて表示
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: profileSize, height: profileSize)
                                        .clipShape(Circle()) // 画像を丸く切り抜く
                                    // 👇 0.4 から 0.6 くらいに上げると、より「半分以上はみ出した」感じになります
                                        .offset(y: profileSize * 0.6)
                                    
                                } else {
                                    // ✅ 画像がない場合：人型アイコンを灰色で表示
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable() // アイコンもサイズ変更可能にする
                                        .scaledToFit()
                                        .frame(width: profileSize, height: profileSize)
                                        .foregroundColor(.gray.opacity(0.6)) // アイコンの色を灰色に
                                        .background(Color.white) // アイコンの後ろを白にして透過を防ぐ
                                        .clipShape(Circle()) // 背景色も含めて丸くする
                                        .offset(y: profileSize * 0.6)
                                }
                            }
                            // ZStack自体の高さをカバー写真と同じにする（下のVStackへの影響を防ぐ）
                            .frame(width: screenWidth, height: coverHeight)
                            .padding(.bottom,80)
                            
                            
                            VStack{
                                HStack{
                                    Spacer()
                                    
                                    Text(profileViewModel.user.userName)
                                        .font(.title)
                                    
                                    Spacer()
                                }
                                // --- 自己紹介文エリア ---
                                Text(profileViewModel.user.selfIntroduction)
                                    .font(.body)
                                    .padding(.top, 1)
                                    .padding(.bottom, 15)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(4) // 行間を少し空けると読みやすい
                                    .fixedSize(horizontal: false, vertical: true) // テキストが長くても省略されないようにする
                                //                                HStack(spacing: 2){
                                //                                    profileViewModel.profileStat(count: "12", label: "投稿")
                                //                                    profileViewModel.profileStat(count: "150", label: "フォロワー")
                            }
                        }
                    }
                    
                    
                    VStack{
                        // 1. 見出し部分（Picker）
                        Picker("", selection: $profileSelection) {
                            Text("Post").tag(0)
                            Text("Favorite Coffee").tag(1)
                            Text("Favorite Tool").tag(2)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                        .pickerStyle(.segmented) // セグメント表示
                        
                        TabView(selection: $profileSelection) {
                            PostView(title: "Favorite Coffee",viewModel: viewModel,profileViewModel: profileViewModel)
                                .tag(0)
                            MyProfileView(title: "Post",profileViewModel: profileViewModel)
                                .tag(1)
                            FavoriteToolView(title: "Favorite Tool")
                                .tag(2)
                        }
                        .tabViewStyle(.page)
                        .frame(height: 600)
                        .ignoresSafeArea()
                    }
                }
                .navigationTitle("プロフィール")
                .navigationBarTitleDisplayMode(.inline)
            }
            .sheet(isPresented: $profileViewModel.isProfileEditSheet){
                ProfileEditView(profileViewModel: $profileViewModel)
                    .onAppear {
                        // 👈 ここが重要！
                        // メインの viewModel が持っている logs を、profileViewModel の logs にコピーする
                        profileViewModel.logs = viewModel.logs
                    }
            }
        }
    }
}



struct MyProfileView: View {
    let title: String
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        ScrollView{
            LazyVStack(spacing: 20){
                VStack(alignment: .leading, spacing: 10){
                    HStack{
                        Text("お気に入りのコーヒー：")
                        Text(profileViewModel.user.favoriteCoffee)
                    }
                    
                    RatingView(
                        label: "苦味",
                        rating: profileViewModel.user.probitter,
                        maxRating: profileViewModel.maxRating
                    )
                    
                    RatingView(
                        label: "酸味",
                        rating: profileViewModel.user.proacidity,
                        maxRating: profileViewModel.maxRating
                    )
                    
                    RatingView(
                        label: "コク",
                        rating: profileViewModel.user.probody,
                        maxRating: profileViewModel.maxRating
                    )
                    
                    RatingView(
                        label: "香り",
                        rating: profileViewModel.user.proaroma,
                        maxRating: profileViewModel.maxRating
                    )
                    
                    HStack{
                        Text("フレーバー：")
                        Text("アッシー")
                    }
                }
                
            }
        }
    }
}

struct PostView: View {
    let title: String
    var viewModel: ViewModel
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        // 縦方向のスワイプをシミュレート
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.logs) { log in
                    VStack {
                        PostCardView(log: log, viewModel: viewModel,profileViewModel: profileViewModel,isEditable: false)
                    }
                }
            }
        }
    }
}

struct FavoriteToolView: View {
    let title: String
    
    var body: some View {
        ScrollView{
            LazyVStack(spacing: 20){
                EmptyView()
            }
        }
    }
}

/// 単一のポストカード
struct PostCardView: View {
    let log: Log
    var viewModel: ViewModel
    var profileViewModel: ProfileViewModel
    var isEditable: Bool
    
    @State private var dragOffset: CGSize = .zero
    let profileSize: CGFloat = 40
    
    // ✅ 算出プロパティにしてコードをスッキリさせる
    // 投稿者が自分かどうかを判定
    private var isMyPost: Bool {
        log.user.userNo == profileViewModel.user.userNo
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // --- ヘッダーエリア ---
            HStack(spacing: 10) {
                // プロフィール画像：自分なら最新の image、他人なら log 保持の image
                if let uiImage = isMyPost ? profileViewModel.profileImage : nil { // 他人の画像保持ロジックがあればここに入れる
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: profileSize, height: profileSize)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: profileSize, height: profileSize)
                        .foregroundColor(.gray.opacity(0.6))
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                // 名前：自分なら最新の userName、他人なら log の userName
                Text(isMyPost ? profileViewModel.user.userName : log.user.userName)
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                Text(log.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 自分自身の投稿の時だけメニュー（編集・削除）を出す
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
            .padding(.horizontal, 5)
            
            // --- 画像・テキストオーバーレイエリア ---
            ZStack {
                if let uiImage = log.logImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(4/3, contentMode: .fill) // .fitから.fillに変更して枠を埋める
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    // 画像がない時のプレースホルダー
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .aspectRatio(4/3, contentMode: .fit)
                }
                
                // ドラッグ可能な情報タグ
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text("Shop: \(log.shopName)")
                        Text("Origin: \(log.countryName)") // County -> Origin
                        Text("Farm: \(log.farmName)")
                        Text("Roast: \(log.roastLevel)")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .padding(10)
                .background(.ultraThinMaterial) // iOSらしい半透明背景
                .cornerRadius(8)
                .foregroundColor(.primary)
                .offset(
                    x: isEditable ?viewModel.currentOffsetX + dragOffset.width : log.tagX,
                    y: isEditable ?viewModel.currentOffsetY + dragOffset.height : log.tagY
                )
                .gesture(
                    isEditable ?
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            // ViewModel の値を直接更新して、動かした位置を「確定」させる
                            viewModel.currentOffsetX += value.translation.width
                            viewModel.currentOffsetY += value.translation.height
                            dragOffset = .zero// アニメーションや微調整用のドラッグ距離はリセット
                        }
                    : nil
                    
                    // アニメーションや微調整用のドラッグ距離はリセット
                    
                    
                )
            }
            VStack{
                //　星評価
                HStack {
                    Text("BitternessRating:")
                        .padding(8)
                    let avgRating =  Double(log.bitternessrating1 + log.bitternessrating2) / 2.0
                    ZStack(alignment: .leading) {
                        // 1. 背景の星（グレー・5つ）
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star")
                            }
                        }
                        
                        // 2. 前面の星（オレンジ・5つ）
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                            }
                        }
                        // 3. ここがポイント：前面の星を「平均値の割合」で切り抜く
                        .mask(
                            GeometryReader { geometry in
                                Rectangle()
                                // 星5つ分（100%）に対して、(rating / 5) の幅だけ表示する
                                    .frame(width: geometry.size.width * CGFloat(avgRating / 5.0))
                            }
                        )
                    }
                }
                
                HStack {
                    Text("AcidityRating:")
                        .padding(8)
                    let avgRating =  Double(log.acidityrating1 + log.acidityrating2) / 2.0
                    ZStack(alignment: .leading) {
                        // 1. 背景の星（グレー・5つ）
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star")
                            }
                        }
                        
                        // 2. 前面の星（オレンジ・5つ）
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                            }
                        }
                        // 3. ここがポイント：前面の星を「平均値の割合」で切り抜く
                        .mask(
                            GeometryReader { geometry in
                                Rectangle()
                                // 星5つ分（100%）に対して、(rating / 5) の幅だけ表示する
                                    .frame(width: geometry.size.width * CGFloat(avgRating / 5.0))
                            }
                        )
                    }
                }
                
                HStack {
                    Text("BodyRating:")
                        .padding(8)
                    let avgRating =  Double(log.bodyrating1 + log.bodyrating2) / 2.0
                    ZStack(alignment: .leading) {
                        // 1. 背景の星（グレー・5つ）
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star")
                            }
                        }
                        
                        // 2. 前面の星（オレンジ・5つ）
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                            }
                        }
                        // 3. ここがポイント：前面の星を「平均値の割合」で切り抜く
                        .mask(
                            GeometryReader { geometry in
                                Rectangle()
                                // 星5つ分（100%）に対して、(rating / 5) の幅だけ表示する
                                    .frame(width: geometry.size.width * CGFloat(avgRating / 5.0))
                            }
                        )
                    }
                }
                
                HStack {
                    Text("AromaRating:")
                        .padding(8)
                    ZStack(alignment: .leading) {
                        // 1. 背景の星（グレー・5つ）
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star")
                            }
                        }
                        
                        // 2. 前面の星（オレンジ・5つ）
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                            }
                        }
                        // 3. ここがポイント：前面の星を「平均値の割合」で切り抜く
                        .mask(
                            GeometryReader { geometry in
                                Rectangle()
                                // 星5つ分（100%）に対して、(rating / 5) の幅だけ表示する
                                    .frame(width: geometry.size.width * CGFloat(Double(log.aromarating) / 5.0))//Doubleどうしてこれが必要なのか
                            }
                        )
                    }
                }
                HStack {
                    Text("香りの種類:") // ラベル
                    Text(log.aromaComment)
                }
            }
            .padding(15)
            .foregroundColor(.black)
        }
        .padding(40)
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
            logImage: UIImage(systemName: "cup.and.saucer.fill"),
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
            logImage: UIImage(systemName: "bean.fill"),
            tagX: -30,
            tagY: -10
        )
    ]
    
    // 2. プロフィール用の ViewModel を作成
    let sharedProfileViewModel = ProfileViewModel()
    sharedProfileViewModel.user = sampleUser
    // 初期表示のために同期
    sharedProfileViewModel.logs = sharedViewModel.logs
    
    // 3. ProfileView 本体をプレビュー
    return ProfileView(
        viewModel: sharedViewModel,
        profileViewModel: sharedProfileViewModel
    )
}

