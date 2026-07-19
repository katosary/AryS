//
//  SearchView.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/17.
//

import SwiftUI

struct SearchView: View {
    @State var searchViewModel = SearchViewModel()
    
    @State private var searchText = ""
    @State private var isShowingFilter = false
    
    var body: some View {
        // 全体の背景色をシステム背景に設定
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack(spacing: 7) {
                    // 検索テキストフィールド
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary) // .grayから変更
                        
                        TextField("検索キーワードを入力", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground)) // .systemGray6から変更
                    .cornerRadius(10)
                    
                    // 条件指定ボタン
                    Button {
                        isShowingFilter = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color(.secondarySystemBackground)) // .systemGray6から変更
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
                Text("検索結果の表示エリア")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("検索")
        .sheet(isPresented: $isShowingFilter) {
            NavigationStack {
                SearchTipsView(title:"検索条件")
            }
        }
    }
}



struct LocationSelectionView: View {
    @Bindable var searchViewModel: SearchViewModel
    
    // シートを閉じるための環境変数
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                // ドラムロール形式のピッカー
                Picker("都道府県", selection: $searchViewModel.location) {
                    ForEach(searchViewModel.prefectures, id: \.self) { pref in
                        // pref は「東京都」などの文字列。そのまま表示し、tagにも文字列を渡す
                        Text(pref).tag(pref)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden() // 中央に配置
                
                Text("選択中: \(searchViewModel.location.isEmpty ? "未選択" : searchViewModel.location)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .navigationTitle("都道府県を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
        // 年齢と同じくハーフモーダルで表示
        .presentationDetents([.height(300)])
    }
}







