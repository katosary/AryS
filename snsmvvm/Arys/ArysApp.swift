//
//  ArysApp.swift
//
//
//  Created by katoso on 2026/02/25.
//

import SwiftUI
import FirebaseCore



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
struct ArysApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var bookmarkManager = BookmarkManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(bookmarkManager) // ← environmentObject から environment に変更
        }
    }
}
