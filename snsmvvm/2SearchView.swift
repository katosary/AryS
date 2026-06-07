//
//  SearchView.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/17.
//

import SwiftUI

struct SearchView: View {
    var viewModel: ViewModel
    var profileViewModel: ProfileViewModel
    @Environment(SearchViewModel.self) var searchViewModel
    
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
                ConditionView(title:"検索条件", viewModel: viewModel, profileViewModel: profileViewModel, searchViewModel: searchViewModel)
            }
        }
    }
}

struct ConditionView: View {
    let title: String
    @Bindable var viewModel: ViewModel
    @Bindable var profileViewModel: ProfileViewModel
    @Bindable var searchViewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List { // Listを使うとダークモード時の背景色が自動で綺麗になります
            Button(action: { searchViewModel.isShowingLocationPicker = true }) {
                HStack {
                    Text("所在地から探す").foregroundColor(.primary)
                    Spacer()
                    Text(searchViewModel.location.isEmpty ? "選択してください" : searchViewModel.location)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $searchViewModel.isShowingLocationPicker) {
                LocationSelectionView(searchViewModel: searchViewModel)
            }
            
            Button(action: { searchViewModel.isShowingCountryPicker = true }) {
                HStack {
                    Text("生産国から探す").foregroundColor(.primary)
                    Spacer()
                    Text(searchViewModel.searchCountry.isEmpty ? "選択してください" : searchViewModel.searchCountry)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $searchViewModel.isShowingCountryPicker) {
                SearchCountryView(searchViewModel: searchViewModel)
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完了") { dismiss() }
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



struct SearchCountryView: View {
    @Bindable var searchViewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchViewModel.regionOrder, id: \.self) { region in
                    Section(header: Text(region)) { // ここは選択不可の見出し
                        ForEach(searchViewModel.regions[region] ?? [], id: \.self) { country in
                            Button(action: {
                                searchViewModel.searchCountry = country
                                dismiss() // 選択したらシートを閉じる
                            }) {
                                HStack {
                                    Text(country)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if searchViewModel.searchCountry == country {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("生産国を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}




#Preview {
    SearchView(
        viewModel: ViewModel(),
        profileViewModel: ProfileViewModel(),
    )
}

