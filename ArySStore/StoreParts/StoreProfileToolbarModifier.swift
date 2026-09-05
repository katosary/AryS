//
//  StoreProfileToolbarModifier.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreProfileToolbarModifier: ViewModifier {
    // 必要に応じてViewModelやStore用Managerを追加してください
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        // TODO: ストア用のメニュー画面をここに実装
                        StoreMenuView()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
                 
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .renderingMode(.template) // ★ 画像をテンプレートとして扱い、色を変更可能にする
                        .resizable()
                        .foregroundColor(.white)  // ★ ロゴを白色に指定
                        .scaledToFit()
                        .frame(height: 44)
                }
                 
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        // TODO: ストア用の通知画面をここに実装
                        StoreNotificationView()
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - プレースホルダー画面（必要に応じて別ファイルに移動してください）
struct StoreMenuView: View {
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            Text("ストアメニュー画面（準備中）")
                .foregroundColor(.white)
        }
    }
}

struct StoreNotificationView: View {
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            Text("ストア通知画面（準備中）")
                .foregroundColor(.white)
        }
    }
}
