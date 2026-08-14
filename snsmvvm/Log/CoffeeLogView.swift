//
//  CoffeeLogView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/01.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct CoffeeLogView: View {
    let log: Log
    let author: User?
    let authorName: String
    let isEditable: Bool
    
    @Environment(BookmarkManager.self) private var bookmarkManager
    @Environment(ProfileViewModel.self) var profileViewModel
    
    // View 側で ViewModel を @State で保持する
    @State private var coffeeLogViewModel: CoffeeLogViewModel
    @State private var isShowingDetailSheet = false
    
    init(log: Log, author: User?, authorName: String, isEditable: Bool = false) {
        self.log = log
        self.author = author
        self.authorName = authorName
        self.isEditable = isEditable
        
        // 引数なしで初期化できるようにする
        _coffeeLogViewModel = State(initialValue: CoffeeLogViewModel(log: log))
    }
    
    var body: some View {
        // body が描画されるタイミングで、必要に応じて bookmarkManager を同期する
        let _ = coffeeLogViewModel.bookmarkManager = bookmarkManager
        // 画面幅（左右のパディング16px×2を引いた幅）を基準に高さを一定にする
        let screenWidth = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.width ?? 393
        let cardWidth = screenWidth - 32
        let cardHeight = cardWidth * (16 / 9)
        
        VStack(spacing: 0) {
            ZStack {
                // --- 背景画像エリア ---
                Group {
                    if let previewImage = log.previewImage {
                        Image(uiImage: previewImage)
                            .resizable()
                            .scaledToFill()
                    } else if let urlString = log.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .clipped()
                
                // --- 右上のメニューボタン ---
                HStack(spacing: 12) {
                    Text(log.createdAt, style: .date).font(.caption).foregroundColor(.secondary)
                    if coffeeLogViewModel.isMyPost {
                        Menu {
                            Button { coffeeLogViewModel.onEdit() } label: { Label("編集", systemImage: "pencil") }
                            Button(role: .destructive) { coffeeLogViewModel.deletePost() } label: { Label("削除", systemImage: "trash") }
                        } label: { Image(systemName: "ellipsis").padding(5).foregroundColor(.primary) }
                    } else {
                        Menu {
                            Button(role: .destructive) { } label: { Label("報告する", systemImage: "exclamationmark.bubble") }
                        } label: { Image(systemName: "ellipsis").padding(5).foregroundColor(.primary) }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                .padding(16)
                
                // --- 中央のコーヒー情報 ---
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        let displayUser = coffeeLogViewModel.isMyPost ? profileViewModel.user : author
                        Text(displayUser?.userName ?? authorName)
                    }
                    Text("Shop \(log.shopName)")
                    Text("Country \(log.countryName)")
                    
                    // --- Bitterness ---
                    VStack(alignment: .leading, spacing: 6) {
                        let rating = Double(log.bitternessrating)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("Bitterness").font(.subheadline).bold()
                            EmptyhRatingView(rating: rating)
                        }
                    }
                    
                    // --- Acidity ---
                    VStack(alignment: .leading, spacing: 6) {
                        let rating = Double(log.acidityrating)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("Acidity").font(.subheadline).bold()
                            EmptyhRatingView(rating: rating)
                        }
                    }
                    
                    // --- Body ---
                    VStack(alignment: .leading, spacing: 6) {
                        let rating = Double(log.bodyrating)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("Body").font(.subheadline).bold()
                            EmptyhRatingView(rating: rating)
                        }
                    }
                    
                    // --- Aroma ---
                    VStack(alignment: .leading, spacing: 6) {
                        let rating = Double(log.aromarating)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("Aroma").font(.subheadline).bold()
                            EmptyhRatingView(rating: rating)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                .padding(16)
                .onTapGesture { if !isEditable { isShowingDetailSheet = true } }
                
                // --- 右下のアクションボタン ---
                VStack(spacing: 15) {
                    // いいねボタンとカウント
                    VStack(spacing: 4) {
                        Button {
                            coffeeLogViewModel.toggleLike()
                        } label: {
                            Image(systemName: coffeeLogViewModel.isLikedByMe ? "heart.fill" : "heart")
                                .font(.system(size: 28))
                                .foregroundColor(coffeeLogViewModel.isLikedByMe ? .red : .white)
                        }
                        
                        // いいねの数（ログの likesCount を表示）
                        Text("\(coffeeLogViewModel.log.likesCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Button {
                        coffeeLogViewModel.toggleSave(bookmarkManager: bookmarkManager)
                    } label: {
                        Image(systemName: bookmarkManager.isSaved(log.id) ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 28))
                            .foregroundColor(bookmarkManager.isSaved(log.id) ? .yellow : .white)
                    }
                    
//                    // --- ③ シェアボタン ---
//                    Button {
//                    } label: {
//                        Image(systemName: "arrowshape.turn.up.right.fill")
//                            .font(.system(size: 28))
//                    }
                    
                    // --- ④ プロフィール画像 ---
                    Button {
                        coffeeLogViewModel.onTapProfile()
                    } label: {
                        HStack {
                            let displayUser = coffeeLogViewModel.isMyPost ? profileViewModel.user : author
                            if let urlString = displayUser?.profileImageUrl, !urlString.isEmpty, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                                placeholder: { Circle().fill(Color.gray) }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill").resizable().frame(width: 40, height: 40).foregroundColor(.gray)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                .padding(16)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // CoffeeLogView.swift の body 内の sheet 部分
        .sheet(isPresented: $isShowingDetailSheet) {
            CoffeeLogDetailView(
                log: log,
                author: author,
                authorName: authorName,
                coffeeLogViewModel: coffeeLogViewModel
            )
        }
    }
}

