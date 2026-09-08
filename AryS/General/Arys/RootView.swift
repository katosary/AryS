//
//  RootView.swift
//  AryS
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RootView: View {
    @State private var authManager = AuthManager()
    @State private var userManager = UserManager()
    @State private var bookmarkManager = BookmarkManager()
    @State private var profileViewModel = ProfileViewModel()
    
    // 店舗用データを保持する場合の状態
    @State private var currentStore: Store? = nil
    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            Group {
                if authManager.isLoggedIn {
                    if !authManager.isEmailVerified {
                        // 1. メール認証がまだの場合（共通またはアカウント種別で出し分け可能）
                        EmailVerificationNoticeView()
                    } else {
                        // 2. 認証済み：userTypeによって画面を切り替える
                        switch authManager.userType {
                        case .general:
                            HomeView()
                                .task {
                                    if let uid = Auth.auth().currentUser?.uid {
                                        await userManager.fetchCurrentUser(uid: uid)
                                    }
                                }
                                .task {
                                    await profileViewModel.loadUserData()
                                }
                                .task(id: Auth.auth().currentUser?.uid) {
                                    bookmarkManager.startListening()
                                }
                                
                        case .store:
                            if let store = currentStore {
                                StoreHomeView(store: store)
                                    .task {
                                        await fetchCurrentStore()
                                    }
                            } else {
                                Color.clear
                                    .task {
                                        await fetchCurrentStore()
                                    }
                            }
                            
                        case .unknown:
                            // 判定中のローディングなど
                            ProgressView()
                                .task {
                                    if (Auth.auth().currentUser?.uid) != nil {
                                        // 再度判定を促す
                                        await fetchCurrentStore()
                                    }
                                }
                        }
                    }
                } else {
                    // 3. 未ログイン（一般ログイン画面または選択画面を表示）
                    LoginView()
                }
            }
            .environment(authManager)
            .environment(userManager)
            .environment(profileViewModel)
            .environment(bookmarkManager)
            .zIndex(1)
            
            // --- スプラッシュ画面 ---
            if isShowingSplash {
                SplashView() // または店舗・一般共通のデザイン
                    .transition(.opacity)
                    .zIndex(2)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                isShowingSplash = false
                            }
                        }
                    }
            }
        }
    }
    
    // 店舗データを取得するヘルパー
    private func fetchCurrentStore() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let document = try await Firestore.firestore().collection("stores").document(uid).getDocument()
            if document.exists {
                self.currentStore = try document.data(as: Store.self)
            }
        } catch {
            print("店舗データ取得エラー: \(error)")
        }
    }
}
