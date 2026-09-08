//
//  StoreProfileTopView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct StoreProfileTopView: View {
    @State private var store: Store?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                // 1. 店舗の紹介写真（縦3・横4の比率 / 3:4）
                ZStack(alignment: .bottomLeading) {
                    if let imageURLString = store?.storeImageURL,
                       let url = URL(string: imageURLString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure(_), .empty:
                                Color.black.opacity(0.3)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.fill")
                                                .font(.system(size: 30))
                                            Text("お店の紹介写真（焙煎機や焙煎風景など）")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.white.opacity(0.7))
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .aspectRatio(4/3, contentMode: .fit)
                        .cornerRadius(12)
                        .clipped()
                    } else {
                        Color.black.opacity(0.3)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 30))
                                    Text("お店の紹介写真（焙煎機や焙煎風景など）")
                                        .font(.caption)
                                }
                                .foregroundColor(.white.opacity(0.7))
                            )
                            .aspectRatio(4/3, contentMode: .fit)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                
                // 2. 店舗名・都道府県
                VStack(alignment: .leading, spacing: 4) {
                    Text(store?.storeName ?? "読み込み中...")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("\(store?.prefecture ?? "---")・自家焙煎コーヒー専門店")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                
                // 3. 焙煎士情報（全体がボタンになっており詳細へ遷移）
                NavigationLink {
                    if let store = store {
                        RoasterDetailView(store: store)
                    } else {
                        Text("データを読み込んでいます...")
                            .foregroundColor(.white)
                    }
                } label: {
                    HStack(spacing: 16) {
                        if let urlString = store?.roasterImageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("焙煎士：\(store?.roasterName ?? "未設定")")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(store?.roasterBio.isEmpty == false ? "「\(store!.roasterBio)」" : "「一杯のコーヒーに物語と感動を込めて...」")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(16)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                
                // 4. お客様からのレビュー（最近のもの1つ）
                VStack(alignment: .leading, spacing: 8) {
                    Text("お客様からの声（最新）")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white.opacity(0.9))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("★★★★★")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Spacer()
                            Text("2026/09/01")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Text("「エチオピアの浅煎り豆を購入しました。香りが華やかで、冷めてからもフルーツのような甘みが続きとても美味しかったです！」")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 4) {
                    Image(systemName: "chevron.compact.down")
                        .font(.title2)
                    Text("スワイプして詳細を見る")
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            fetchStoreData()
        }
    }
    
    private func fetchStoreData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let document = try await Firestore.firestore().collection("stores").document(uid).getDocument()
                if document.exists {
                    self.store = try document.data(as: Store.self)
                }
                isLoading = false
            } catch {
                isLoading = false
                print("店舗データの取得・デコードに失敗しました: \(error)")
            }
        }
    }
}
