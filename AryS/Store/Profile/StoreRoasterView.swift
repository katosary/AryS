//
//  RoasterDetailView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct RoasterDetailView: View {
    let store: Store
    
    var body: some View {
        ZStack {
            Color(red: 89/255, green: 61/255, blue: 43/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ヘッダー（アイコンと名前）
                    HStack(spacing: 16) {
                        if let urlString = store.roasterImageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(store.roasterName.isEmpty ? "未設定" : store.roasterName)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                Text(store.roastingExperience.isEmpty ? "焙煎歴: 未設定" : "焙煎歴: \(store.roastingExperience)")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.3))
                    
                    // 一言・こだわりセクション
                    VStack(alignment: .leading, spacing: 8) {
                        Text("一言・こだわり")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(store.roasterBio.isEmpty ? "自己紹介文が未設定です。" : "「\(store.roasterBio)」")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    // 使用焙煎機セクション
                    VStack(alignment: .leading, spacing: 8) {
                        Text("使用焙煎機")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white.opacity(0.7))
                            Text(store.roastingMachine.isEmpty ? "未設定" : store.roastingMachine)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("焙煎士について")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}
