//
//  ProfileView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @State var profileViewModel = ProfileViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var profileSelection = 0
    @State private var isMenuPresented = false
    
    // 親側では「背景をぼかす・縮めるため」のフラグだけを残す
    @State private var isDetailShowing = false
    
    // --- 【設定値】サイズ・デザイン ---
    let coverHeight: CGFloat = 250
    let profileSize: CGFloat = 100
    let overlapAmount: CGFloat = 0.6
    let profileBorderColor: Color = .white
    
    var body: some View {
        GeometryReader { outerGeometry in
            let totalWidth = outerGeometry.size.width
            let totalHeight = outerGeometry.size.height
            
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 0) {
                            // --- 1. 上部：画像重なりエリア ---
                            ZStack(alignment: .bottom) {
                                Color(.secondarySystemBackground)
                                    .frame(height: coverHeight)
                                
                                VStack {
                                    Text("自分が投稿したポストの中でいちばんのお気に入りを選べるボタンを作り、\nそれをここに表示する")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                
                                Group {
                                    if let urlString = profileViewModel.user.profileImageUrl, let url = URL(string: urlString) {
                                        // URLから読み込む
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: profileSize, height: profileSize)
                                        .clipShape(Circle())
                                    } else {
                                        // URLがない場合はデフォルトアイコン
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.systemGray3))
                                            .frame(width: profileSize, height: profileSize)
                                    }
                                }
                                .frame(width: profileSize, height: profileSize)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 3))
                                .offset(y: profileSize * overlapAmount)
                            }
                            .padding(.bottom, profileSize * overlapAmount + 10)
                            
                            // --- 3. ユーザー名 ＆ 自己紹介 ---
                            VStack(spacing: 8) {
                                Text(profileViewModel.user.userName).font(.title2).bold()
                                
                                // 出身地を表示するコード
                                if !profileViewModel.user.prefecture.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: "mappin.and.ellipse")
                                        Text(profileViewModel.user.prefecture)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                }
                                
                                Text(profileViewModel.user.selfIntroduction)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 10)
                            
                            // --- 4. タブ切り替え ---
                            Picker("", selection: $profileSelection) {
                                Text("Post").tag(0)
                                Text("Favorite Coffee").tag(1)
                                Text("Favorite Tool").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            
                            // --- 5. コンテンツエリア ---
                            switch profileSelection {
                            case 0:
                                ProfileCoffeeLogView(
                                    totalWidth: totalWidth,
                                    totalHeight: totalHeight,
                                    isDetailShowing: $isDetailShowing
                                )
                            case 1:
                                ProfileFavoriteCoffeeView(profileViewModel: profileViewModel)
                            case 2:
                                ProfileFavoriteToolView(profileViewModel: profileViewModel)
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .navigationTitle("プロフィール")
                    .background(Color(.systemBackground))
                }
                .background(Color(.systemBackground))
                .customPullToRefresh {
                    if let currentUid = Auth.auth().currentUser?.uid {
                        await profileViewModel.loadProfile(uid: currentUid)
                    }
                }
                // 子ビューのシートが開くと連動して動く設定
                .scaleEffect(isDetailShowing ? 0.93 : 1.0)
                .blur(radius: isDetailShowing ? 8 : 0)
                .disabled(isDetailShowing)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: isDetailShowing)
        // 💡 ここ（.taskの前あたり）に追加する！
        .onAppear {
            if let currentUid = Auth.auth().currentUser?.uid {
                Task {
                    await profileViewModel.loadProfile(uid: currentUid)
                }
            }
        }
        .task {
            // 初回起動時（データがまだ空のとき）だけ読み込む
            if profileViewModel.user.userName.isEmpty, let currentUid = Auth.auth().currentUser?.uid {
                await profileViewModel.loadProfile(uid: currentUid)
            }
        }
    }
}
