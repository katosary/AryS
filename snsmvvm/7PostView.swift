//
//  7PostView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/01.
//

import SwiftUI
import PhotosUI
import FirebaseAuth


struct PostCardView: View {
    let log: Log
    let author: User?
    let authorName: String
    @Environment(ViewModel.self) var viewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    var isEditable: Bool
    var onDelete: () -> Void
    var onEdit: () -> Void
    
    @State private var isShowingDetailSheet = false
    let profileSize: CGFloat = 40
    @State private var dragOffset: CGSize = .zero
    
    private var isMyPost: Bool {
        log.userId == String(profileViewModel.user.userNo)
    }
    
    // 💡 修正: プロフィール表示ロジック
    // 他人の投稿の場合、Logモデルにユーザー名や写真URLが含まれていないなら、
    // "Unknown" や固定のアイコンを表示する形になります。
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // 💡 ここを修正：自分ならViewModelのuser、他人なら引数のauthorを使う
                let displayUser = isMyPost ? profileViewModel.user : author
                
                // 💡 displayUser を使って表示ロジックを組む
                if let urlString = displayUser?.profileImageUrl, !urlString.isEmpty, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(Color.gray)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                
                Text(authorName) 
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
                            onEdit()
                        } label: {
                            Label("編集", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            onDelete()
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
                // PostCardView.swift の画像表示部分を修正
                Group {
                    if let urlString = log.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        // log.logImages.first を削除し、デフォルト表示にする
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary.opacity(0.1))
                            .overlay(
                                VStack(spacing: 10) {
                                    Image(systemName: "photo.on.rectangle").font(.largeTitle)
                                    Text("No Image").font(.subheadline).foregroundColor(.secondary)
                                }
                            )
                    }
                }
                .aspectRatio(4/3, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
