//
//  RoasterDetailView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct RoasterDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("焙煎士の詳細プロフィール")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Text("ここに焙煎士の経歴、コーヒーに対するこだわり、受賞歴などの詳細なストーリーを表示します。")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
        }
        .navigationTitle("焙煎士について")
        .navigationBarTitleDisplayMode(.inline)
    }
}
