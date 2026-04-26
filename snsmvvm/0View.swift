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
    @State var profileViewModel = ProfileViewModel()
    @State var matchingViewModel = MatchingViewModel()
    
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
    }
    
    //画面下の5つのタブ
    func tabBar() -> some View {
        TabView(selection: $viewModel.selectedTab){
            // 1. ホーム
            HomeView(viewModel: viewModel,profileViewModel: profileViewModel)
                .tabItem {
                    Image(systemName: viewModel.selectedTab == 0 ? "house.fill" : "house")
                    Text("ホーム")
                }
                .tag(0)
            
            // 2. 検索
            SearchView(viewModel:viewModel)
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
            MatchingView(matchingViewModel: matchingViewModel)
                .tabItem {
                    Image(systemName: "crown")
                    Text("ランキング")
                }
                .tag(3)
            
            // 5. プロフィール
            ProfileView(profileViewModel: profileViewModel)
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
}

// MARK: - Preview
#Preview {
    ContentView()
}
