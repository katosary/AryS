//
//  ContentView.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/12.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedSelection = 0
 
    var body: some View {
        ZStack(alignment: .top) {
            // 背景をシステム背景色にする
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            TabView(selection: $selectedSelection){
                FollowersView()
                    .tag(0)
                RecommendView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack(spacing: 20){
                Button(action: { selectedSelection = 0 }) {
                    Text("フォロー中")
                        .font(.system(size: 18, weight: .bold))
                        // 選択中は primary(黒/白)、未選択は secondary(グレー)
                        .foregroundStyle(selectedSelection == 0 ? Color.primary : Color.secondary)
                }
                
                Button(action: { selectedSelection = 1 }) {
                    Text("おすすめ")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(selectedSelection == 1 ? Color.primary : Color.secondary)
                }
            }
            .padding(.top)
        }
    }
}


