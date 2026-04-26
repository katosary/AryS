//
//  HomeView.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/12.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedSelection = 0
    @State var viewModel: ViewModel
    @State var profileViewModel: ProfileViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedSelection){
                FollowersView(title: "フォロー中", viewModel: viewModel,profileViewModel: profileViewModel)
                    .tag(0)
                RecommendView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            //`.page`　ページ風にスワイプができるようになる。下にページ数を模したドットが出る
            //`(indexDisplayMode: .never)　ドットを非表示にする
            
            //            .ignoresSafeArea() //役割：画面の上下の「余白（安全地帯）」を無視して、全画面表示にする
            
            HStack(spacing: 20){
                Button(action: { selectedSelection = 0 }) {
                    VStack(spacing: 4) {
                        Text("フォロー中")
                            .font(.system(size: 18, weight: .bold))
                        
                        //                        // 選択中のアンダーライン
                        //                        Rectangle()
                        //                            .fill(selectedSelection == 0 ? .white : .clear)
                        //                            .frame(width: 40, height: 2)
                    }
                }
                
                Button(action: { selectedSelection = 1 }) {
                    VStack(spacing: 4) {
                        Text("おすすめ")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
            }
            .padding(.top)
        }
    }
}

// 各リストの表示用
struct FollowersView: View {
    let title: String
    var viewModel: ViewModel
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        // 縦方向のスワイプをシミュレート
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.logs) { log in
                    ZStack {
                        LogView(log: log, viewModel: viewModel,profileViewModel: profileViewModel)
                            .padding()
                    }
                    .containerRelativeFrame(.vertical) // 親（画面）の縦幅いっぱいに広げる // 画面いっぱいに表示
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging) // 縦のスワイプを1枚ずつ止まるようにする（iOS 17+）
        .ignoresSafeArea()
    }
}

struct RecommendView: View{
    var body: some View{
        EmptyView()
    }
}

struct LogView: View {
    let log: Log
    var viewModel: ViewModel
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        // 投稿カードの内容
        VStack{
            // ユーザー名・作成日・メニュー
            HStack{
                Text(log.user.userNo == profileViewModel.user.userNo ? profileViewModel.user.userName : log.user.userName) // 投稿者
                //log.user.userNo == profileViewModel.user.userNo ? profileViewModel.user.userName : log.user.userNameここがめちゃ大事っぽい
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
            ZStack(alignment: .bottomTrailing){
                // --- 画像の表示処理 ---
                if let uiImage = log.logImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill() // 枠いっぱいに広げる
                        .aspectRatio(4/3, contentMode: .fit) // 👈 これを追加（4:3を維持）
                        .frame(maxWidth: .infinity)
                        .clipped() // 枠からはみ出た分をカット
                        .cornerRadius(12)
                }
                VStack{
                    HStack {
                        Text("Shop:") // ラベル
                        Text(log.shopName)
                    }
                    // コーヒー(国名)
                    HStack {
                        Text("County:") // ラベル
                        Text(log.countryName)
                    }
                    HStack {
                        Text("Farmer:") // ラベル
                        Text(log.farmName)
                    }
                    HStack {
                        Text("RoastLevel:") // ラベル
                        Text(log.roastLevel)
                    }
                    
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
                }
                .padding(15)
                .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(10)
    }
}
