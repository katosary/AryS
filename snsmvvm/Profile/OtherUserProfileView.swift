//
//  OtherUserProfileView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/14.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - OtherUserProfileView (指定された User オブジェクトを受け取る版)
struct OtherUserProfileView: View {
    let user: User? // NavigationDestinationから渡されるUser
    
    @State private var viewModel = OtherProfileViewModel()
    @State private var isDetailShowing = false
    @State private var scrollPosition: Int? = 0
    
    // ブロック・通報用の状態
    @State private var showingBlockAlert = false
    @State private var showingReportAlert = false
    @State private var reportReason = ""
    @Environment(\.dismiss) private var dismiss
    
    let profileSize: CGFloat = 80
    
    var body: some View {
        GeometryReader { outerGeometry in
            let totalWidth = outerGeometry.size.width
            let totalHeight = outerGeometry.size.height
            
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                // 全体を上下ページングするための親 ScrollView
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        // 1ページ目：プロフィール詳細とツール情報
                        OtherProfileDetailContentView(
                            user: viewModel.user,
                            totalWidth: totalWidth,
                            totalHeight: totalHeight,
                            profileSize: profileSize
                        )
                        .frame(width: totalWidth, height: totalHeight)
                        .containerRelativeFrame(.vertical)
                        
                        // 2ページ目：コーヒーログ一覧グリッド
                        OtherProfileCoffeeLogGridView(
                            viewModel: viewModel,
                            totalWidth: totalWidth,
                            totalHeight: totalHeight
                        )
                        .frame(width: totalWidth, height: totalHeight)
                        .containerRelativeFrame(.vertical)
                    }
                }
                .scrollTargetBehavior(.paging)
                .refreshable {
                    if let userId = user?.id {
                        await viewModel.loadUserData(userId: userId)
                    }
                }
                .navigationTitle(viewModel.user.userName.isEmpty ? (user?.userName ?? "プロフィール") : viewModel.user.userName)
                .navigationBarTitleDisplayMode(.inline)
                // MARK: - 右上にブロック・通報メニューを追加
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                showingBlockAlert = true
                            } label: {
                                Label("このユーザーをブロックする", systemImage: "hand.raised")
                            }
                            
                            Button(role: .destructive) {
                                showingReportAlert = true
                            } label: {
                                Label("このユーザーを通報する", systemImage: "flag")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.body)
                        }
                    }
                }
                // ブロック確認アラート
                .alert("ユーザーのブロック", isPresented: $showingBlockAlert) {
                    Button("ブロックする", role: .destructive) {
                        Task {
                            if let targetId = user?.id {
                                await viewModel.blockUser(targetUserId: targetId)
                                dismiss() // ブロックしたら前の画面に戻る
                            }
                        }
                    }
                    Button("キャンセル", role: .cancel) {}
                } message: {
                    Text("このユーザーをブロックすると、お互いの投稿が表示されなくなります。")
                }
                // 通報入力アラート
                .alert("ユーザーの通報", isPresented: $showingReportAlert) {
                    TextField("通報の理由（例：不適切な発言など）", text: $reportReason)
                    Button("送信", role: .destructive) {
                        Task {
                            if let targetId = user?.id {
                                await viewModel.reportUser(targetUserId: targetId, reason: reportReason)
                                reportReason = ""
                            }
                        }
                    }
                    Button("キャンセル", role: .cancel) {}
                } message: {
                    Text("運営チームが内容を確認し、適切に対処いたします。")
                }
                .background(Color(.systemBackground))
                .onAppear {
                    if let initialUser = user {
                        viewModel.user = initialUser
                        if let userId = initialUser.id, !userId.isEmpty {
                            Task {
                                await viewModel.loadUserData(userId: userId)
                            }
                        } else {
                            print("Error: initialUser.id is nil or empty.")
                        }
                    }
                }
                .scaleEffect(isDetailShowing ? 0.93 : 1.0)
                .blur(radius: isDetailShowing ? 8 : 0)
                .disabled(isDetailShowing)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: isDetailShowing)
    }
}

// MARK: - 他人用の 1ページ目プロフィール詳細ビュー
struct OtherProfileDetailContentView: View {
    let user: User
    let totalWidth: CGFloat
    let totalHeight: CGFloat
    let profileSize: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // 1. カバー画像 + 道具の情報オーバーレイ
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let urlString = user.favoriteToolImageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color(.secondarySystemBackground)
                                .overlay(ProgressView())
                        }
                    } else {
                        Color(.secondarySystemBackground)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                .frame(width: totalWidth)
                .aspectRatio(4/3, contentMode: .fit)
                .clipped()
                
                let toolData: [(String, String)] = [
                    ("ドリッパー", user.dripper ?? ""),
                    ("ペーパー", user.paperFilter ?? ""),
                    ("ケトル", user.kettle ?? ""),
                    ("サーバー", user.server ?? ""),
                    ("スケール", user.scale ?? ""),
                    ("ミル", user.mill ?? ""),
                    ("グラインダー", user.grinder ?? ""),
                    ("マシン", user.espressoMachine ?? ""),
                    ("プレス", user.frenchPress ?? "")
                ].filter { !$0.1.isEmpty }
                
                if !toolData.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(toolData, id: \.0) { label, value in
                            HStack(spacing: 6) {
                                Text(label)
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.white.opacity(0.8))
                                Text(value)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .black.opacity(0.8), radius: 2)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [.black.opacity(0.7), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
            }
            
            // 2. アイコン、ユーザー名、自己紹介など
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Group {
                        if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(.systemGray3))
                        }
                    }
                    .frame(width: profileSize, height: profileSize)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.userName)
                            .font(.title3)
                            .bold()
                        
                        HStack(spacing: 8) {
                            if user.userAge > 0 {
                                Text("\(user.userAge)歳")
                            }
                            if !user.prefecture.isEmpty {
                                HStack(spacing: 2) {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text(user.prefecture)
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                if !user.selfIntroduction.isEmpty {
                    Text(user.selfIntroduction)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // お気に入りのコーヒー（国名）
                HStack(alignment: .top) {
                    Text("国")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.secondary)
                        .frame(width: 50, alignment: .leading)
                    
                    Text(user.favoriteCoffee.isEmpty ? "未登録" : user.favoriteCoffee)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .bold()
                }
                
                // 味のパラメータ
                VStack(spacing: 8) {
                    parameterRow(label: "苦味", rating: user.probitter)
                    parameterRow(label: "酸味", rating: user.proacidity)
                    parameterRow(label: "コク", rating: user.probody)
                    parameterRow(label: "香り", rating: user.proaroma)
                }
                .padding(.top, 4)
                
                // フレーバー
                HStack(alignment: .top) {
                    Text("フレーバー")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .leading)
                    
                    Text(user.proflavor.isEmpty ? "未登録" : user.proflavor)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .bold()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 下スワイプを促すアイコン
            VStack(spacing: 4) {
                Image(systemName: "chevron.compact.down")
                    .font(.title2)
                Text("下へスワイプして投稿を見る")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
            .padding(.bottom, 40)
        }
    }
    
    @ViewBuilder
    private func parameterRow(label: String, rating: Int) -> some View {
        HStack(spacing: 15) {
            Text(label)
                .font(.subheadline)
                .frame(width: 45, alignment: .leading)
            
            EmptyRatingView(rating: Double(rating))
        }
        .padding(.trailing, 5)
    }
}

// MARK: - 他人用の 2ページ目グリッドビュー
struct OtherProfileCoffeeLogGridView: View {
    @Bindable var viewModel: OtherProfileViewModel
    let totalWidth: CGFloat
    let totalHeight: CGFloat
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.logs) { log in
                    NavigationLink(destination: OtherProfileCoffeeLogFullscreenView(
                        viewModel: viewModel,
                        currentLogId: log.id
                    )) {
                        if let imageUrlString = log.imageUrl, let url = URL(string: imageUrlString) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: totalWidth / 3, height: totalWidth / 3)
                            .clipped()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 他人用のフルスクリーン縦スクロール投稿ビュー
struct OtherProfileCoffeeLogFullscreenView: View {
    @Bindable var viewModel: OtherProfileViewModel
    @State var currentLogId: String?
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.logs) { log in
                        AsyncPostRow(
                            post: log,
                            fetchUser: { userId in
                                try await viewModel.fetchUser(userId: userId)
                            }
                        ) { author in
                            CoffeeLogView(
                                log: log,
                                author: author,
                                authorName: author.userName,
                                isEditable: false
                            )
                            .padding(.horizontal, 16)
                        }
                        .frame(maxWidth: .infinity)
                        .containerRelativeFrame(.vertical) { length, _ in
                            length
                        }
                        .id(log.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $currentLogId)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(viewModel.user.userName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
