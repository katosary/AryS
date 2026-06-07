//
//  RootView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/07.
//


import SwiftUI
import FirebaseAuth

struct RootView: View {
    @ObservedObject var authManager = AuthManager()
    
    init() {
            try? Auth.auth().signOut()
        }
    
    var body: some View {
        Group {
            let _ = print("現在のログイン状態: \(authManager.isLoggedIn)")
            if authManager.isLoggedIn {
                ContentView()
            } else {
                LoginView(authManager: authManager)
            }
        }
    }
}
