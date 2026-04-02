//
//  ContentView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/25.
//

// このファイルは、投稿一覧を表示し、新規投稿や編集・削除を行うためのメイン画面(View)を定義します

// MARK: - View 本体

import SwiftUI

/// 投稿一覧画面。投稿の一覧表示、投稿作成シートの表示、各投稿の編集・削除を提供します
struct ContentView: View {
    /// 投稿データや画面状態(シート表示など)を管理する ViewModel
    @State var viewModel = ViewModel()
    
    /// 画面全体のレイアウト。NavigationStack でタイトルを表示し、メインコンテンツを配置
    var body: some View {
        NavigationStack{
            content()
                .navigationTitle(Text("アプリ名")) // 画面タイトル
                .background(Color.brown.opacity(0.5)) // 画面全体の背景色
        }
    }
}

// MARK: - サブビュー(レイアウト分割)
extension ContentView {
    /// 画面下部のフローティングボタンを重ねたメインコンテンツのコンテナ
    func content() -> some View  {
        tabBar()
        //        ZStack(alignment: .bottomTrailing) { // 投稿一覧の上に右下固定の入力ボタンを重ねる
        //            // 画面下のタブ
        //            tabBar()
        //            // 投稿一覧(スクロール)
        //            mainView()
        //            // 右下の新規入力ボタン
        //            inputButton()
        //        }
    }
    
    /// 投稿一覧をスクロール表示する領域
    func mainView() -> some View {
        ScrollView { // 縦スクロール
            LazyVStack{ // 遅延ロードで縦方向に積む
                ForEach(viewModel.posts) { post in
                    // 個々の投稿カード
                    postView(post)
                }
            }
        }
        .sheet(isPresented: $viewModel.isEditSheet) {
            if let targetPost = viewModel.selectedPost {
                PostEditView(viewModel: $viewModel, post: targetPost)
                    .id(targetPost.id)
            }
        }
    }
    
//    /// 新規投稿用の入力シートを表示するフローティングボタン
//    func inputButton() -> some View {
//        // タップで入力シートを開く
//        Button {
//            viewModel.iswritingsheet = true // 入力シート表示フラグ
//        } label: {
//            Image(systemName: "cup.and.saucer.fill")
//                .font(.system(size: 35, weight: .semibold)) // アイコンサイズ
//                .foregroundStyle(.white)
//                .padding(20)
//                .background(Color.brown)
//                .clipShape(Circle())
//                .shadow(radius: 3)
//        }
//        .sheet(isPresented: $viewModel.iswritingsheet) { // 新規投稿シート
//            SendMessageView(viewModel: viewModel)
//                .padding(20)
//        }
//        .padding(12) // 画面端からの余白
//    }
    
    //画面下の5つのタブ
    func tabBar() -> some View {
        TabView(selection: $viewModel.selectedTab){
            // 1. ホーム
            mainView()
                .tabItem {
                    Image(systemName: viewModel.selectedTab == 0 ? "house.fill" : "house")
                    Text("ホーム")
                }
                .tag(0)
            
            // 2. 検索
            Text("検索画面")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("見つける")
                }
                .tag(1)
            
            // 3. 投稿 (プラスアイコン)
            PostSendView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "plus.app")
                    Text("投稿")
                }
                .tag(2)
            
            // 4. リール
            Text("ランキング")
                .tabItem {
                    Image(systemName: "crown")
                    Text("ランキング")
                }
                .tag(3)
            
            // 5. プロフィール
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("プロフィール")
                }
                .tag(4)
        }
        .accentColor(.primary) // アイコン選択時の色（黒/白）
//        .onChange(of: viewModel.selectedTab){ oldValue,newValue in
//            if newValue == 2 {
//                viewModel.selectedTab = oldValue
//                viewModel.iswritingsheet = true // 入力シート表示フラグ
//            }
//        }
//        .sheet(isPresented: $viewModel.iswritingsheet) { // 新規投稿シート
//            SendMessageView(viewModel: viewModel)
//        }
    }
        
        
        /// 単一の投稿を表示するカードビュー
        func postView(_ post: Post) -> some View {
            // 投稿カードの内容
            VStack{
                // ユーザー名・作成日・メニュー
                HStack{
                    Text(post.user.userName) // 投稿者
                        .frame(maxWidth: 150, alignment: .leading)
                    Text(post.createdAt,style:.date) // 作成日
                        .frame(maxWidth: 150, alignment: .trailing)
                    Menu {
                        // 編集メニュー
                        Button {
                            viewModel.selectedPost = post
                            // 編集シートを表示
                            viewModel.isEditSheet = true
                        } label: {
                            Label("編集", systemImage: "pencil")
                        }
                        // 対象の投稿を削除
                        Button {
                            viewModel.deletePost(targetPost: post)
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
                    Text(post.coffeeName)
                }
                .frame(maxWidth: 300, alignment: .leading)
                // 感想本文
                HStack {
                    Text("感想：") // ラベル
                    Text(post.content)
                }
                .frame(maxWidth: 300, alignment: .leading)
                //　星評価
                HStack {
                    Text("評価：")
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: post.rating)  //rating: post.ratingを入力すると全部解決した
                            .foregroundColor(number > post.rating ? viewModel.offColor : viewModel.onColor)
                    }
                }
                .frame(maxWidth: 300, alignment: .leading)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(10)
        }
    }
    
    // MARK: - Preview
    #Preview {
        ContentView()
    }
