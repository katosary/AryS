//
//  7PostView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/01.
//

import SwiftUI
import PhotosUI


struct PostCardView: View {
    let log: Log
    @Environment(ViewModel.self) var viewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    var isEditable: Bool
    
    @State private var dragOffset: CGSize = .zero
    @State private var isShowingDetailSheet = false
    let profileSize: CGFloat = 40
    
    // 投稿者が自分かどうかを判定
    private var isMyPost: Bool {
        log.user.userNo == profileViewModel.user.userNo
    }
    
    // 💡 表示に使うユーザー情報を動的に切り替えるプロパティ
    private var displayUser: User {
        isMyPost ? profileViewModel.user : log.user
    }
    
    var body: some View {
        // ⚠️ bodyの直下を大きなVStackで包むことで、全体のレイアウトを縦に並べます
        VStack(spacing: 16) {
            
            // --- ① ヘッダーエリア ---
            HStack(spacing: 12) { // ユーザ情報とメニューを横並びにするためHStackがおすすめ
                // --- B. プロフィール写真 ---
                Group {
                    if let uiImage = displayUser.profileImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray.opacity(0.6))
                            .background(Color.white)
                    }
                }
                .frame(width: profileSize, height: profileSize)
                .clipShape(Circle())
                
                Text(displayUser.userName)
                    .font(.title2)
                    .bold()
                
                
                
                
                Spacer()
                
                // 日付
                Text(log.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 編集・削除メニュー
                if isMyPost {
                    Menu {
                        Button {
                            viewModel.selectedPost = log
                            viewModel.isEditSheet = true
                        } label: {
                            Label("編集", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            viewModel.deleteLog(targetPost: log)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .padding(5)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 12)
            
            ZStack(alignment: .bottomLeading) {
                if let urlString = log.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                } else if let firstImage = log.logImages.first {
                    // ローカル画像
                    Image(uiImage: firstImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 400) // 上の AsyncImage と高さを合わせると綺麗です
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // 画像がない場合
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .overlay(
                            VStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle").font(.largeTitle)
                                Text("No Image").font(.subheadline).foregroundColor(.secondary)
                            }
                        )
                }
                
                
                //                // ドラッグ・タップ可能な情報タグ
                //                VStack(alignment: .leading, spacing: 4) {
                //                    Group {
                //                        Text("Shop: \(log.shopName)")
                //                        Text("Origin: \(log.countryName)")
                //                        Text("Farm: \(log.farmName)")
                //                        Text("Roast: \(log.roastLevel)")
                //                    }
                //                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                //                }
                //                .padding(10)
                //                .background(.ultraThinMaterial)
                //                .cornerRadius(8)
                //                .foregroundColor(.primary)
                //                .offset(
                //                    x: isEditable ? viewModel.currentOffsetX + dragOffset.width : log.tagX,
                //                    y: isEditable ? viewModel.currentOffsetY + dragOffset.height : log.tagY
                //                )
                //                // 💡 タップジェスチャーを追加（編集モードじゃない時はシートを開く）
                //                .onTapGesture {
                //                    if !isEditable {
                //                        isShowingDetailSheet = true
                //                    }
                //                }
                //                // 💡 ドラッグは編集モードの時だけ有効にする
                //                .gesture(
                //                    isEditable ?
                //                    DragGesture()
                //                        .onChanged { value in
                //                            dragOffset = value.translation
                //                        }
                //                        .onEnded { value in
                //                            viewModel.currentOffsetX += value.translation.width
                //                            viewModel.currentOffsetY += value.translation.height
                //                            dragOffset = .zero
                //                        }
                //                    : nil
                //                )
                // --- 情報タグ（offsetを削除して固定配置） ---
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text("Shop: \(log.shopName)")
                        Text("Origin: \(log.countryName)")
                        Text("Farm: \(log.farmName)")
                        Text("Roast: \(log.roastLevel)")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                }
                .padding(16) // 左下の端から少し余白を作る
                
                // 💡 タップジェスチャーはそのまま有効
                .onTapGesture {
                    if !isEditable {
                        isShowingDetailSheet = true
                    }
                }
                // 💡 下から出てくる詳細シートの定義
                .sheet(isPresented: $isShowingDetailSheet) {
                    NavigationStack {
                        // GeometryReaderを一番外側にするのがポイントです
                        GeometryReader { geometry in
                            ScrollView {
                                VStack(spacing: 0) {
                                    
                                    // --- 1. 画像エリア ---
                                    if let urlString = log.imageUrl, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: geometry.size.width, height: geometry.size.height * 0.45)
                                        .clipped()
                                    } else if let firstImage = log.logImages.first {
                                        Image(uiImage: firstImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: geometry.size.width, height: geometry.size.height * 0.45)
                                            .clipped()
                                    }
                                    // --- 2. 下部：詳細エリア ---
                                    VStack(alignment: .leading, spacing: 18) {
                                        Text("Coffee Review")
                                            .font(.title2).bold()
                                            .padding(.top, 20)
                                        
                                        VStack(alignment: .leading, spacing: 18) {
                                            // --- Bitterness ---
                                            VStack(alignment: .leading, spacing: 6) {
                                                let avgBitterness = Double(log.bitternessrating1 + log.bitternessrating2) / 2.0
                                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                                    Text("Bitterness").font(.subheadline).bold()
                                                    Text(String(format: "%.1f", avgBitterness)).font(.subheadline).bold().foregroundColor(.orange)
                                                }
                                                RatingView(rating: avgBitterness, maxRating: 5)
                                            }
                                            
                                            // --- Acidity ---
                                            VStack(alignment: .leading, spacing: 6) {
                                                let avgAcidity = Double(log.acidityrating1 + log.acidityrating2) / 2.0
                                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                                    Text("Acidity").font(.subheadline).bold()
                                                    Text(String(format: "%.1f", avgAcidity)).font(.subheadline).bold().foregroundColor(.orange)
                                                }
                                                RatingView(rating: avgAcidity, maxRating: 5)
                                            }
                                            
                                            // --- Body ---
                                            VStack(alignment: .leading, spacing: 6) {
                                                let avgBody = Double(log.bodyrating1 + log.bodyrating2) / 2.0
                                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                                    Text("Body").font(.subheadline).bold()
                                                    Text(String(format: "%.1f", avgBody)).font(.subheadline).bold().foregroundColor(.orange)
                                                }
                                                RatingView(rating: avgBody, maxRating: 5)
                                            }
                                            
                                            // --- Aroma ---
                                            VStack(alignment: .leading, spacing: 6) {
                                                let aromaDouble = Double(log.aromarating)
                                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                                    Text("Aroma").font(.subheadline).bold()
                                                    Text(String(format: "%.1f", aromaDouble)).font(.subheadline).bold().foregroundColor(.orange)
                                                }
                                                RatingView(rating: aromaDouble, maxRating: 5)
                                            }
                                            
                                            // --- 香りのコメント ---
                                            if !log.aromaComment.isEmpty {
                                                VStack(alignment: .leading, spacing: 6) {
                                                    Text("香りの種類:")
                                                        .font(.subheadline)
                                                        .bold()
                                                        .foregroundColor(.secondary)
                                                    Text(log.aromaComment)
                                                        .font(.body)
                                                }
                                                .padding(.top, 8)
                                            }
                                        }
                                    }
                                    .padding(24)
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                            }
                        }
                        .presentationDetents([.fraction(1.0)]) // 💡 100%表示
                        .presentationDragIndicator(.visible)   // 💡 つまみを表示
                        .presentationCornerRadius(20)          // 💡 シート全体の角丸
                    }
                }
            }
        }
    }
}

