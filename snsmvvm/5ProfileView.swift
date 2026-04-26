//
//  ProfileView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/22.
//

import SwiftUI

struct ProfileView: View {
    @State private var profileSelection = 0
    var viewModel = ViewModel()
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
                    VStack { //これから並べるVStackの中のものを先頭寄せにして並べるものの間に15のスペースを作る
                        
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
                                    Color.clear
                                        .frame(width: 30, height: 30)
                                    
                                    Spacer()
                                    
                                    Text(profileViewModel.userName)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    // プロフィール編集ボタン
                                    Button{
                                        profileViewModel.isProfileEditSheet = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .frame(width: 30, height: 30)
                                            .background(Color(.systemGray6))
                                            .foregroundColor(.primary)
                                            .cornerRadius(8)
                                    }
                                    .frame(alignment: .trailing)
                                }
                                HStack(spacing: 2){
                                    profileViewModel.profileStat(count: "12", label: "投稿")
                                    profileViewModel.profileStat(count: "150", label: "フォロワー")
                                }
                            }
                        }
                        
                        
                        VStack{
                            TabView(selection: $profileSelection) {
                                MyProfileView(title: "自己紹介",profileViewModel: profileViewModel)
                                    .tag(0)
                                FavoriteCoffeeView(title: "好みのコーヒー",profileViewModel: profileViewModel)
                                    .tag(1)
                                PostView(title: "投稿",viewModel: viewModel,profileViewModel: profileViewModel)
                                    .tag(2)
                                FavoriteToolView(title: "お気に入りの道具")
                                    .tag(3)
                            }
                            .tabViewStyle(.page)
                            .frame(height: 600)
                            .ignoresSafeArea()
                        }
                        //                    VStack{
                        //                        HStack{
                        //                            Text("お気に入りのコーヒー：")
                        //                            Text(viewModel.favoriteCoffee)
                        //                        }
                        //                        .padding(30)
                        //                    }
                    }
                    .navigationTitle("プロフィール")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .sheet(isPresented: $profileViewModel.isProfileEditSheet){
                    ProfileEditView(profileViewModel: $profileViewModel)
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
                // --- 自己紹介文エリア ---
                VStack(alignment: .leading, spacing: 5) {
                    Text("自己紹介")
                        .font(.headline)
                    
                    Text(profileViewModel.selfIntroduction)
                        .font(.body)
                        .lineSpacing(4) // 行間を少し空けると読みやすい
                        .fixedSize(horizontal: false, vertical: true) // テキストが長くても省略されないようにする
                }
            }
        }
    }
}

struct FavoriteCoffeeView: View {
    let title: String
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        @Bindable var profileViewModel = profileViewModel
        ScrollView{
            LazyVStack(spacing: 20){
                VStack(alignment: .leading, spacing: 10){
                    HStack{
                        Text("お気に入りのコーヒー：")
                        Text(profileViewModel.favoriteCoffee)
                    }
                    
                    RatingView(
                        label: "苦味",
                        rating: profileViewModel.probitter,
                        maxRating: profileViewModel.maxRating
                    )
                    
                    RatingView(
                        label: "酸味",
                        rating: profileViewModel.proacidity,
                        maxRating: profileViewModel.maxRating
                    )
                    
                    RatingView(
                        label: "コク",
                        rating: profileViewModel.probody,
                        maxRating: profileViewModel.maxRating
                    )
                    
                    RatingView(
                        label: "香り",
                        rating: profileViewModel.proaroma,
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
    var viewModel:ViewModel
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        LazyVStack(spacing: 20){
            ForEach(viewModel.logs) { log in
                ProfileLogView(log: log, viewModel: viewModel, profileViewModel: profileViewModel)
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

/// 単一の投稿を表示するカードビュー
struct ProfileLogView: View {
    let log: Log
    var viewModel: ViewModel
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        // 投稿カードの内容
        VStack{
            // --- 画像の表示処理 ---
            if let uiImage = log.logImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill() // 枠いっぱいに広げる
                    .frame(maxWidth: .infinity)
                    .frame(height: 200) // 高さを固定
                    .clipped() // 枠からはみ出た分をカット
                    .cornerRadius(12)
            }
            // ユーザー名・作成日・メニュー
            HStack{
                Text(log.user.userName) // 投稿者
                    .frame(maxWidth: 150, alignment: .leading)
                Text(log.createdAt,style:.date) // 作成日
                    .frame(maxWidth: 150, alignment: .trailing)
                Menu {
                    // 編集メニュー
                    Button {
                        viewModel.selectedPost = log
                        // 編集シートを表示
                        viewModel.isEditSheet = true
                    } label: {
                        Label("編集", systemImage: "pencil")
                    }
                    // 対象の投稿を削除
                    Button {
                        viewModel.deleteLog(targetPost: log)
                    } label: {
                        Label("削除", systemImage: "trash")
                            .padding(8)
                            .foregroundColor(.secondary)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            // コーヒー(国名)
            HStack {
                Text("国名：") // ラベル
                Text(log.countryName)
            }
            .frame(maxWidth: 300, alignment: .leading)
            
            //　星評価
            HStack {
                let avgRating =  Double(log.bitternessrating1 + log.bitternessrating2) / 2.0
                ZStack(alignment: .leading) {
                    // 1. 背景の星（グレー・5つ）
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.gray.opacity(0.3))
                        }
                    }
                    
                    // 2. 前面の星（オレンジ・5つ）
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
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
            .frame(maxWidth: 300, alignment: .leading)
        }
        .padding(20)
        .background(Color.black)
        .cornerRadius(10)
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
