//
//  snsmvvmApp.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/25.
//

import SwiftUI
import FirebaseCore // 必要

// 1. AppDelegateを定義
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Firebase初期化開始！") // これが表示されるはず
        FirebaseApp.configure()
        return true
    }
}

@main
struct snsmvvmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // 💡 @StateObject を @State に変更します
    @State private var authManager = AuthManager()
    @State private var userManager = UserManager()
    @State private var viewModel = ViewModel()
    @State private var profileViewModel = ProfileViewModel()
    @State private var searchViewModel = SearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                // 💡 .environmentObject はそのまま、または .environment で注入
                .environmentObject(authManager)
                .environmentObject(userManager)
                .environment(viewModel)
                .environment(profileViewModel)
                .environment(searchViewModel)
        }
    }
}
