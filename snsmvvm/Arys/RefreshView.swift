
//
//  CustomPullToRefresh.swift
//
//  Created by (あなたのお名前) on (日付).
//

import SwiftUI

// MARK: - A. カスタムリフレッシュビュー（アニメーション本体）
// 💡 これは全ビュー共通で使われます
struct CoffeeRefreshView: View {
    let isRefreshing: Bool
    @State private var degree: Double = 0
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.title3) // バーに馴染むように少し小さく
                .foregroundColor(.orange)
                .rotationEffect(.degrees(degree))
                .animation(
                    isRefreshing ?
                        .linear(duration: 1.0).repeatForever(autoreverses: false) :
                        .default,
                    value: degree
                )
                .onAppear {
                    if isRefreshing { degree = 360 }
                }
                .onChange(of: isRefreshing) { _, newValue in
                    if newValue { degree = 360 } else { degree = 0 }
                }

            Text(isRefreshing ? "読み込み中..." : "引っ張って更新")
                .font(.footnote) // 補足情報なので小さく
                .foregroundColor(.secondary)
        }
        .frame(height: 50) // インジケーターの高さを固定
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6).opacity(0.8)) // 背景をつけて見やすく
    }
}

// MARK: - B. 共通ロジックを持つViewModifier
// 💡 これが肝です。コンテンツをScrollViewで包み、スクロールを検知します。
struct CustomRefreshModifier: ViewModifier {
    // 💡 リフレッシュ時に実行するアクションを受け取る
    let action: () async -> Void
    
    @State private var isRefreshing = false
    @State private var currentOffset: CGFloat = 0
    private let scrollSpace = "PullToRefresh"
    private let triggerThreshold: CGFloat = 80 // リフレッシュを開始する引っ張り量
    private let indicatorHeight: CGFloat = 50 // インジケーターの高さ

    func body(content: Content) -> some View {
        // 💡 コンテンツをScrollViewで包む
        ScrollView {
            ZStack(alignment: .top) {
                // 1. カスタムインジケーター（画面上部に配置）
                if isRefreshing || currentOffset > 10 {
                    CoffeeRefreshView(isRefreshing: isRefreshing)
                        .offset(y: -indicatorHeight)
                }

                // 2. メインコンテンツ
                content
                    .offset(y: isRefreshing ? indicatorHeight : 0) // リフレッシュ中はコンテンツを下げる
                    .animation(.spring(), value: isRefreshing)

                // 3. スクロール検知用の透明なビュー
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named(scrollSpace)).origin.y)
                }
                .frame(height: 0)
            }
        }
        .coordinateSpace(name: scrollSpace) // GeometryReaderが監視する空間を定義
        // 💡 スクロール位置が変わった時の処理
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            currentOffset = offset
            
            // まだリフレッシュ中でなく、閾値を超えて引っ張られたら
            if !isRefreshing && offset > triggerThreshold {
                isRefreshing = true
                
                // 💡 非同期処理を開始
                Task {
                    print("🔄 グローバルリフレッシュ開始")
                    await action() // 渡されたアクションを実行
                    print("✅ グローバルリフレッシュ完了")
                    
                    // アニメーション付きで状態を戻す
                    withAnimation {
                        isRefreshing = false
                    }
                }
            }
        }
    }
}

// MARK: - C. View拡張メソッド（使いやすくするため）
extension View {
    // 💡 各ビューからはこれを呼び出すだけ
    func customPullToRefresh(action: @escaping () async -> Void) -> some View {
        modifier(CustomRefreshModifier(action: action))
    }
}

// MARK: - D. 補助：PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
