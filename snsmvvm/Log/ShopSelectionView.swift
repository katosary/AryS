//
//  ShopSelectionView.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/18.
//

import SwiftUI

struct SelectShopView : View {
    @Environment(ProfileViewModel.self) var profileViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("どこで飲んだコーヒーですか？")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            NavigationLink(destination: CoffeeRecordView()) {
                LogSelectButton(title: "カフェ", subtitle: "お近くの店舗", icon: "mappin.and.ellipse", color: .orange)
            }
            
//            NavigationLink(destination: OnlineShopLogView()) {
//                LogSelectButton(title: "オンラインショップ", subtitle: "お家で楽しむアイテム", icon: "cart.fill", color: .blue)
//            }
//            
//            NavigationLink(destination: QRcoadView()) {
//                LogSelectButton(title: "QRコード", subtitle: "QRコードをお持ちの方はこちら", icon: "qrcode.viewfinder", color: .yellow)
//            }
            Spacer()
        }
        .padding(20)
        .navigationTitle("検索")
    }
}

// ボタンの共通スタイル
struct LogSelectButton: View {
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



