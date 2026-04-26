//
//  SearchView.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/17.
//

import SwiftUI

struct SearchView: View {
    @State var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("どちらを探しますか？")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                // カフェを探すボタン
                NavigationLink(destination: CafeSearchView(title: "カフェ")) {
                    SearchMenuButton(title: "カフェを探す", subtitle: "お近くの店舗をチェック", icon: "mappin.and.ellipse", color: .orange)
                }
                
                // オンラインショップを探すボタン
                NavigationLink(destination: OnlineSearchView(title: "オンラインショップ")) {
                    SearchMenuButton(title: "オンラインショップを探す", subtitle: "お家で楽しむアイテム", icon: "cart.fill", color: .blue)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("検索")
        }
    }
}

// ボタンの共通スタイル
struct SearchMenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(color)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// 遷移先のView（プレースホルダー）
struct CafeSearchView: View {
    let title: String
    var body: some View {
        VStack {
            TextField("所在地から探す", text: .constant(""))
                .textFieldStyle(.roundedBorder)
                .padding()
            Spacer()
        }
        .navigationTitle(title)
    }
}

struct OnlineSearchView: View {
    let title: String
    var body: some View {
        VStack {
            TextField("商品名から探す", text: .constant(""))
                .textFieldStyle(.roundedBorder)
                .padding()
            Spacer()
        }
        .navigationTitle(title)
    }
}
