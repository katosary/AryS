//
//  StoreRootView.swift
//  ArySStore
//
//  Created by katoso on 2026/09/07.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct StoreRootView: View {
    @State private var authManager = AuthManager()
    @State private var currentStore: Store? = nil
    @State private var isLoadingStore = false
    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            Group {
                if authManager.isLoggedIn {
                    if !authManager.isEmailVerified {
                        // 1. ログイン済み・メール未認証
                        StoreEmailVerificationNoticeView()
                    } else {
                        // 2. ログイン済み・メール認証完了
                        Group {
                            if let store = currentStore {
                                StoreHomeView(store: store)
                            } else if isLoadingStore {
                                ProgressView("店舗情報を読み込んでいます...")
                                    .tint(.white)
                            } else {
                                Text("店舗データの取得に失敗しました")
                                    .foregroundColor(.white)
                            }
                        }
                        .task(id: Auth.auth().currentUser?.uid) {
                            await fetchCurrentStore()
                        }
                    }
                } else {
                    // 3. 未ログイン
                    StoreLoginView()
                }
            }
            .environment(authManager)
            .zIndex(1)
            
            // スプラッシュ画面
            if isShowingSplash {
                // 必要に応じて StoreSplashView などを用意
                Color(red: 89/255, green: 61/255, blue: 43/255)
                    .ignoresSafeArea()
                    .overlay(
                        Image(systemName: "storefront.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.white)
                    )
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
        .preferredColorScheme(.dark)
    }
    
    // Firestoreから現在の店舗データを取得する
        private func fetchCurrentStore() async {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            isLoadingStore = true
            
            do {
                let document = try await Firestore.firestore().collection("stores").document(uid).getDocument()
                
                guard document.exists else {
                    print("❌ 指定されたドキュメントが存在しません")
                    isLoadingStore = false
                    return
                }
                
                // ⭕️ document.data(as:) を使うことで @DocumentID やメタデータを含めて自動デコードする
                self.currentStore = try document.data(as: Store.self)
                print("✅ 店舗データの取得に成功しました: \(self.currentStore?.storeName ?? "")")
                
            } catch {
                print("🚨 店舗データ取得・デコードエラー詳細: \(error)")
            }
            isLoadingStore = false
        }}
