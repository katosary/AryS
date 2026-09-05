//
//  ProfileView.swift
//  snsmvvm
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @Environment(AuthManager.self) var authManager
    @Environment(ProfileViewModel.self) var profileViewModel
    @State private var isDetailShowing = false
      
    let profileSize: CGFloat = 80   // アイコンのサイズ
      
    var body: some View {
        GeometryReader { outerGeometry in
            let totalWidth = outerGeometry.size.width
            let totalHeight = outerGeometry.size.height
             
            ZStack {
                AppBackgroundView()

                NavigationStack {
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            ProfileDetailContentView(
                                totalWidth: totalWidth,
                                totalHeight: totalHeight,
                                profileSize: profileSize
                            )
                            .frame(width: totalWidth, height: totalHeight)
                            .containerRelativeFrame(.vertical)
                            .background(Color.clear)
                             
                            ProfileCoffeeLogView(
                                totalWidth: totalWidth,
                                totalHeight: totalHeight
                            )
                            .frame(width: totalWidth, height: totalHeight)
                            .containerRelativeFrame(.vertical)
                            .background(Color.clear)
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    .refreshable {
                        await profileViewModel.loadUserData()
                    }
                    .navigationTitle("プロフィール")
                    .navigationBarTitleDisplayMode(.inline)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                .background(Color.clear)
                .onAppear {
                    Task {
                        await profileViewModel.loadUserData()
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

// MARK: - 1ページ目のプロフィール情報をまとめた独立ビュー
struct ProfileDetailContentView: View {
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(UserManager.self) var userManager
    let totalWidth: CGFloat
    let totalHeight: CGFloat
    let profileSize: CGFloat
      
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                 
                // 1. カバー画像
                ZStack(alignment: .bottomLeading) {
                    Group {
                        if let uiImage = profileViewModel.remoteToolImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
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
                        ("ドリッパー", profileViewModel.user.dripper ),
                        ("ペーパー", profileViewModel.user.paperFilter ),
                        ("ケトル", profileViewModel.user.kettle ),
                        ("サーバー", profileViewModel.user.server ),
                        ("スケール", profileViewModel.user.scale ),
                        ("ミル", profileViewModel.user.mill ),
                        ("グラインダー", profileViewModel.user.grinder ),
                        ("マシン", profileViewModel.user.espressoMachine ),
                        ("プレス", profileViewModel.user.frenchPress )
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
                    }
                }
                 
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .center, spacing: 8) {
                        Spacer()
                        NavigationLink {
                            if let currentUser = userManager.currentUser {
                                ProfileEditView(user: currentUser)
                            } else {
                                ProfileEditView(user: profileViewModel.user)
                            }
                        } label: {
                            Label("プロフィールを編集", systemImage: "pencil")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundColor(.primary)
                        }
                    }
                    HStack(spacing: 20) {
                        // プロフィールアイコン
                        Group {
                            if let uiImage = profileViewModel.remoteProfileImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color(.systemGray3))
                            }
                        }
                        .frame(width: profileSize, height: profileSize)
                        .clipShape(Circle())
                        
                        VStack {
                            HStack(alignment: .center, spacing: 8) {
                                Text(profileViewModel.user.userName)
                                    .font(.title)
                                    .bold()
                         
                                if !profileViewModel.user.prefecture.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "mappin.and.ellipse")
                                        Text(profileViewModel.user.prefecture)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                     
                    Spacer(minLength: 18)
                     
                    if !profileViewModel.user.selfIntroduction.isEmpty {
                        Text(profileViewModel.user.selfIntroduction)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                     
                    Spacer(minLength: 18)
                     
                    HStack(alignment: .top) {
                        Text("あなたのベストコーヒー")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .bold()
                            .frame(width: 200, alignment: .leading)
                         
                        Text(profileViewModel.user.favoriteCoffee.isEmpty ? "未登録" : profileViewModel.user.favoriteCoffee)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .bold()
                    }
                     
                    NavigationLink {
                        ProfileFlavorDetailView()
                    } label: {
                        HStack {
                            Text("好きな味わいをもっと詳しく...")
                                .font(.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(.primary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                 
                VStack(spacing: 4) {
                    Image(systemName: "chevron.compact.down")
                        .font(.title2)
                    Text("スワイプして投稿を見る")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
                .padding(.bottom, 40)
            }
        }
        .background(Color.clear)
    }
}
