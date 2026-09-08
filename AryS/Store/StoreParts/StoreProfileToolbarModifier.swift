//
//  StoreProfileToolbarModifier.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct StoreProfileToolbarModifier: ViewModifier {
    // 編集画面に現在の store データを渡すために binding で受け取る
    @Binding var store: Store?
    
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
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(height: 44)
                }
                 
                // ★ 右側のボタンを NavigationLink によるプッシュ遷移に変更
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        StoreProfileEditView(store: $store)
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}
