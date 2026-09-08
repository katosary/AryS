//
//  StoreProductTimeLineView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/04.
//

import SwiftUI

struct StoreProductTimeLineView: View {
    let product: Product
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255).ignoresSafeArea()
            Text("他ユーザーの投稿タイムライン（タブ2）")
                .foregroundColor(.white)
        }
    }
}
