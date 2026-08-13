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
    
    @Environment(ProfileViewModel.self) var profileViewModel
    
    var onLike: () -> Void
    var isEditable: Bool
    var isSaved: Bool
    var onSave: () -> Void
    var onTapProfile: () -> Void
    var onDelete: () -> Void
    var onEdit: () -> Void
    
    @State private var isShowingDetailSheet = false
    
    private var isMyPost: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return log.userId == currentUid
    }
    
    // 現在のユーザーがいいねしているかどうかを算出
    private var isLikedByMe: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return log.likedUserIds.contains(currentUid)
    }
    
    var body: some View {
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
                    if isMyPost {
                        Menu {
                            Button { onEdit() } label: { Label("編集", systemImage: "pencil") }
                            Button(role: .destructive) { onDelete() } label: { Label("削除", systemImage: "trash") }
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
                        let displayUser = isMyPost ? profileViewModel.user : author
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
                    // --- ① ハート ＆ いいね数 ---
                    VStack(spacing: 2) {
                        Button {
                            onLike()
                        } label: {
                            Image(systemName: isLikedByMe ? "heart.fill" : "heart")
                                .foregroundColor(isLikedByMe ? .red : .white)
                                .font(.system(size: 28))
                        }
                         
                        // ハートの下にいいね数を表示
                        Text("\(log.likesCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                     
                    // --- ② ブックマークボタン ---
                    Button {
                        onSave()
                    } label: {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.white)
                            .font(.system(size: 28))
                    }
                     
                    // --- ③ シェアボタン ---
                    Button {
                    } label: {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .font(.system(size: 28))
                    }
                     
                    // --- ④ プロフィール画像 ---
                    Button {
                        onTapProfile() // 💡 追加：タップされたら外部の処理を呼ぶ
                    } label: {
                        HStack {
                            let displayUser = isMyPost ? profileViewModel.user : author
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
        .sheet(isPresented: $isShowingDetailSheet) {
            detailSheetView
        }
    }
     
    // --- 詳細シート用ビュー ---
    private var detailSheetView: some View {
        NavigationStack {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width
                let cardHeight = cardWidth * (16 / 9)
                 
                ScrollView {
                    VStack(spacing: 0) {
                        Group {
                            if let previewImage = log.previewImage {
                                Image(uiImage: previewImage)
                                    .resizable()
                                    .scaledToFill()
                            } else if let urlString = log.imageUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                                placeholder: { ProgressView() }
                            }
                        }
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                         
                        // --- 2. 下部：詳細エリア ---
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Coffee Review")
                                .font(.title2).bold()
                                .padding(.top, 20)
                             
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Country: \(log.countryName)")
                                Text("Farm: \(log.farmName)")
                                Text("Roast: \(log.roastLevel)")
                                 
                                // --- Bitterness ---
                                VStack(alignment: .leading, spacing: 6) {
                                    let rating = Double(log.bitternessrating)
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Text("Bitterness").font(.subheadline).bold()
                                        Text(String(format: "%.1f", rating)).font(.subheadline).bold().foregroundColor(.orange)
                                    }
                                    CollorRatingView(rating: rating, maxRating: 5)
                                }
                                 
                                // --- Acidity ---
                                VStack(alignment: .leading, spacing: 6) {
                                    let rating = Double(log.acidityrating)
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Text("Acidity").font(.subheadline).bold()
                                        Text(String(format: "%.1f", rating)).font(.subheadline).bold().foregroundColor(.orange)
                                    }
                                    CollorRatingView(rating: rating, maxRating: 5)
                                }
                                 
                                // --- Body ---
                                VStack(alignment: .leading, spacing: 6) {
                                    let rating = Double(log.bodyrating)
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Text("Body").font(.subheadline).bold()
                                        Text(String(format: "%.1f", rating)).font(.subheadline).bold().foregroundColor(.orange)
                                    }
                                    CollorRatingView(rating: rating, maxRating: 5)
                                }
                                 
                                // --- Aroma ---
                                VStack(alignment: .leading, spacing: 6) {
                                    let rating = Double(log.aromarating)
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Text("Aroma").font(.subheadline).bold()
                                        Text(String(format: "%.1f", rating)).font(.subheadline).bold().foregroundColor(.orange)
                                    }
                                    CollorRatingView(rating: rating, maxRating: 5)
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
                                 
                                Text("Shop: \(log.shopName)")
                                 
                                HStack {
                                    let displayUser = isMyPost ? profileViewModel.user : author
                                     
                                    Button {
                                        onTapProfile()
                                    } label: {
                                        HStack {
                                            let displayUser = isMyPost ? profileViewModel.user : author
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
                                     
                                    Text(displayUser?.userName ?? authorName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .presentationDetents([.fraction(1.0)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
    }
}

#Preview {
    let dummyLog = Log(
        id: "sample_id",
        userId: "sample_user",
        shopName: "スターバックス",
        countryName: "エチオピア",
        farmName: "イルガチェフェ",
        roastLevel: "ライトロースト",
        aromarating: 5,
        aromaComment: "フローラルで柑橘系のような爽やかな香り",
        bitternessrating: 2,
        acidityrating: 4,
        bodyrating: 3,
        createdAt: Date(),
        tagX: 0.0,
        tagY: 0.0,
        imageUrl: nil,
        previewImage: nil
    )
     
    CoffeeLogView(
        log: dummyLog,
        author: nil,
        authorName: "CoffeeLover",
        onLike: {},
        isEditable: false,
        isSaved: false,
        onSave: {},
        onDelete: {},
        onEdit: {}
    )
    .environment(ProfileViewModel())
}
