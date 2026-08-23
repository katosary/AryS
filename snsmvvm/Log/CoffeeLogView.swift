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
    
    var onTapMenu: (() -> Void)?
    var onTapLike: (() -> Void)?
    var onTapBookmark: (() -> Void)?
    var onTapProfile: (() -> Void)?
    
    @Environment(BookmarkManager.self) private var bookmarkManager
    @Environment(ProfileViewModel.self) var profileViewModel
    
    @State private var coffeeLogViewModel: CoffeeLogViewModel
    @State private var isShowingDetailSheet = false
    @State private var isShowingEditSheet = false
    
    // ブロック・通報用の状態
    @State private var showingBlockAlert = false
    @State private var showingReportAlert = false
    @State private var reportReason = ""
    
    init(
        log: Log,
        author: User?,
        authorName: String,
        isEditable: Bool = false,
        onTapMenu: (() -> Void)? = nil,
        onTapLike: (() -> Void)? = nil,
        onTapBookmark: (() -> Void)? = nil,
        onTapProfile: (() -> Void)? = nil
    ) {
        self.log = log
        self.author = author
        self.authorName = authorName
        self.isEditable = isEditable
        self.onTapMenu = onTapMenu
        self.onTapLike = onTapLike
        self.onTapBookmark = onTapBookmark
        self.onTapProfile = onTapProfile
        
        let vm = CoffeeLogViewModel(log: log, author: author)
        _coffeeLogViewModel = State(initialValue: vm)
    }
    
    var body: some View {
        let screenWidth = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.width ?? 393
        let cardWidth = screenWidth - 32
        let cardHeight = cardWidth * (16 / 9)
         
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    // --- 1. 背景画像エリア ---
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
                     
                    // --- 2. 左下のコーヒー情報 ---
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            let displayUser = coffeeLogViewModel.isMyPost ? profileViewModel.user : author
                            Text(displayUser?.userName ?? authorName)
                        }
                        Text("Shop \(log.shopName)")
                        
                        // 💡 ブレンド名（存在する場合のみ、またはそのまま表示）
                        if !log.blend.isEmpty {
                            Text("Blend: \(log.blend)")
                        }
                        
                        Text("Country \(log.countryName)")

                        // 全体を包む親 VStack の spacing も狭くする（例: spacing: 6）
                        VStack(alignment: .leading, spacing: 6) {
                            
                            // --- Bitterness ---
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Bitterness")
                                    .font(.subheadline)
                                    .bold()
                                    .frame(width: 90, alignment: .leading)
                                EmptyRatingView(rating: Double(log.bitternessrating))
                            }
                            
                            // --- Acidity ---
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Acidity")
                                    .font(.subheadline)
                                    .bold()
                                    .frame(width: 90, alignment: .leading)
                                EmptyRatingView(rating: Double(log.acidityrating))
                            }
                            
                            // --- Body ---
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Body")
                                    .font(.subheadline)
                                    .bold()
                                    .frame(width: 90, alignment: .leading)
                                EmptyRatingView(rating: Double(log.bodyrating))
                            }
                            
                            // --- Sweetness ---
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Sweetness")
                                    .font(.subheadline)
                                    .bold()
                                    .frame(width: 90, alignment: .leading)
                                EmptyRatingView(rating: Double(log.sweetnessrating))
                            }
                            
                            // --- Flavor ---
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Flavor")
                                    .font(.subheadline)
                                    .bold()
                                    .frame(width: 90, alignment: .leading)
                                EmptyRatingView(rating: Double(log.flavorrating))
                            }
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.compact.down")
                                .font(.title2)
                            Text("View More...")
                                .font(.caption)
                        }
                        .onTapGesture {
                            isShowingDetailSheet = true
                        }
                    }
                    .frame(maxWidth: cardWidth * 0.65, alignment: .leading)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                     
                    // --- 3. 右上のメニューボタン ---
                    HStack(spacing: 12) {
                        Text(log.createdAt, style: .date).font(.caption).foregroundColor(.secondary)
                         
                        if let customMenuAction = onTapMenu {
                            Button(action: customMenuAction) {
                                Image(systemName: "ellipsis").padding(5).foregroundColor(.primary)
                            }
                        } else {
                            if coffeeLogViewModel.isMyPost {
                                Menu {
                                    Button { isShowingEditSheet = true } label: { Label("編集", systemImage: "pencil") }
                                    Button(role: .destructive) { coffeeLogViewModel.deletePost() } label: { Label("削除", systemImage: "trash") }
                                } label: { Image(systemName: "ellipsis").padding(5).foregroundColor(.primary) }
                            } else {
                                Menu {
                                    Button(role: .destructive) {
                                        showingBlockAlert = true
                                    } label: {
                                        Label("このユーザーをブロックする", systemImage: "hand.raised")
                                    }
                                     
                                    Button(role: .destructive) {
                                        showingReportAlert = true
                                    } label: {
                                        Label("この投稿を報告する", systemImage: "exclamationmark.bubble")
                                    }
                                } label: { Image(systemName: "ellipsis").padding(5).foregroundColor(.primary) }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                    .padding(16)
                     
                    // --- 4. 右下のアクションボタン ---
                    VStack(spacing: 15) {
                        VStack(spacing: 4) {
                            Button {
                                if let customLike = onTapLike {
                                    customLike()
                                } else {
                                    coffeeLogViewModel.toggleLike()
                                }
                            } label: {
                                Image(systemName: coffeeLogViewModel.isLikedByMe ? "heart.fill" : "heart")
                                    .font(.system(size: 28))
                                    .foregroundColor(coffeeLogViewModel.isLikedByMe ? .red : .white)
                            }
                             
                            Text("\(coffeeLogViewModel.log.likesCount)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                         
                        Button {
                            if let customBookmark = onTapBookmark {
                                customBookmark()
                            } else {
                                coffeeLogViewModel.toggleSave(bookmarkManager: bookmarkManager)
                            }
                        } label: {
                            Image(systemName: bookmarkManager.isSaved(log.id) ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 28))
                                .foregroundColor(bookmarkManager.isSaved(log.id) ? .yellow : .white)
                        }
                         
                        Button {
                            if let customProfile = onTapProfile {
                                customProfile()
                            } else {
                                coffeeLogViewModel.onTapProfile(currentProfileUser: profileViewModel.user)
                            }
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
        }
        .navigationDestination(
            isPresented: Binding(
                get: { coffeeLogViewModel.shouldNavigateToProfile },
                set: { coffeeLogViewModel.shouldNavigateToProfile = $0 }
            )
        ) {
            OtherUserProfileView(user: coffeeLogViewModel.targetUserForProfile)
        }
        .sheet(isPresented: $isShowingDetailSheet) {
            CoffeeLogDetailView(
                log: log,
                author: author,
                authorName: authorName,
                coffeeLogViewModel: coffeeLogViewModel
            )
        }
        .sheet(isPresented: $isShowingEditSheet) {
            PostEditView(post: .constant(log))
        }
        // ブロック確認アラート
        .alert("ユーザーのブロック", isPresented: $showingBlockAlert) {
            Button("ブロックする", role: .destructive) {
                Task {
                    await profileViewModel.blockUser(targetUserId: log.userId)
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("このユーザーをブロックすると、お互いの投稿が表示されなくなります。")
        }
        // 通報入力アラート
        .alert("投稿の報告", isPresented: $showingReportAlert) {
            TextField("報告の理由（例：不適切な内容など）", text: $reportReason)
            Button("送信", role: .destructive) {
                Task {
                    // 修正箇所：postId: log.id を追加
                    await profileViewModel.reportUser(targetUserId: log.userId, postId: log.id, reason: reportReason)
                    reportReason = ""
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("運営チームが内容を確認し、適切に対処いたします。")
        }
    }
}
