//
//  StoreAnalyticsView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/05.
//

import SwiftUI

struct StoreAnalyticsView: View {
    @State private var analyticsTab: Int = 0
    @State private var isProfitView: Bool = false
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- 1. グラフエリア（縦3・横4の比率 / タブスワイプ切替） ---
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("売上・実績グラフ")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // 1つ目のタブ（折れ線グラフ）の時だけ売上/利益の切り替えボタンを表示
                            if analyticsTab == 0 {
                                Button {
                                    isProfitView.toggle()
                                } label: {
                                    Text(isProfitView ? "利益表示" : "売上表示")
                                        .font(.caption)
                                        .bold()
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // グラフ用のTabView（横スワイプ）
                        TabView(selection: $analyticsTab) {
                            // 1つ目：折れ線グラフ（ダミー）
                            ZStack {
                                Color.black.opacity(0.3)
                                VStack(spacing: 8) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 40))
                                        .foregroundColor(.yellow)
                                    Text(isProfitView ? "【折れ線】利益の推移グラフ" : "【折れ線】売上の推移グラフ")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .tag(0)
                            
                            // 2つ目：棒グラフ（月毎の売り上げ推移）
                            ZStack {
                                Color.black.opacity(0.3)
                                VStack(spacing: 8) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.green)
                                    Text("【棒グラフ】月毎の売上推移")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .tag(1)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .aspectRatio(4/3, contentMode: .fit)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                    
                    // --- 2. 前月と今月の収支比較セクション ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("収支比較（前月 vs 今月）")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 0) {
                            analyticsRow(title: "売上", lastMonth: "120,000円", thisMonth: "145,000円")
                            Divider().background(Color.white.opacity(0.2))
                            analyticsRow(title: "生豆", lastMonth: "30,000円", thisMonth: "35,000円")
                            Divider().background(Color.white.opacity(0.2))
                            analyticsRow(title: "包装費", lastMonth: "5,000円", thisMonth: "6,000円")
                            Divider().background(Color.white.opacity(0.2))
                            analyticsRow(title: "送料", lastMonth: "15,000円", thisMonth: "18,000円")
                            Divider().background(Color.white.opacity(0.2))
                            analyticsRow(title: "決済手数料", lastMonth: "4,200円", thisMonth: "5,075円")
                            Divider().background(Color.white.opacity(0.2))
                            analyticsRow(title: "原価合計", lastMonth: "54,200円", thisMonth: "64,075円")
                            Divider().background(Color.white.opacity(0.2))
                            analyticsRow(title: "利益", lastMonth: "65,800円", thisMonth: "80,925円", isHighlight: true)
                        }
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                    
                    // --- 3. 購入者一覧セクション ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("購入者一覧")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { _ in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("山田 太郎")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("エチオピア イルガチェフェ 浅煎り")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("2026/09/05 12:30")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(12)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer().frame(height: 30)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("アナリティクス")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 収支行のレイアウトヘルパー
    @ViewBuilder
    private func analyticsRow(title: String, lastMonth: String, thisMonth: String, isHighlight: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .bold(isHighlight)
                .foregroundColor(isHighlight ? .green : .white.opacity(0.8))
            
            Spacer()
            
            HStack(spacing: 20) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("前月")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(lastMonth)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("今月")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(thisMonth)
                        .font(.subheadline)
                        .bold(isHighlight)
                        .foregroundColor(isHighlight ? .green : .yellow)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        StoreAnalyticsView()
            .preferredColorScheme(.dark)
    }
}
