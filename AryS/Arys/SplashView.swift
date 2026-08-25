//
//  SplashView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/24.
//

import SwiftUI

struct SplashView: View {
    // アイコンの背景と同じ茶色
    let backgroundColor = Color(red: 89/255, green: 61/255, blue: 43/255)
    
    // アイコンやロゴの色味を合わせるためのゴールド/ブロンズ系の色
    let themeGoldColor = Color(red: 217/255, green: 185/255, blue: 140/255)
    
    var body: some View {
        ZStack {
            // 背景
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // --- トップのアイコン画像（サイズを大きく調整） ---
                Image("IconEmpty")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // ご希望に合わせて大きめに調整
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
                
                // 「[logo] にログイン」エリア
                HStack(spacing: 6) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text("へようこそ")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // 英語のタグライン
                Text("share their likes, discover your likes.")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .italic()
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                
                Spacer()
                
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashView()
}
