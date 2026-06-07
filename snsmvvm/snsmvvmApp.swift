//
//  snsmvvmApp.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct snsmvvmApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var viewModel = ViewModel()
    @State private var profileViewModel = ProfileViewModel()
    @State private var seachViewModel = SearchViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(viewModel)
                .environment(profileViewModel)
                .environment(seachViewModel)
                .onAppear {
                    Analytics.logEvent(
                        AnalyticsEventScreenView,
                        parameters: [AnalyticsParameterScreenName: "\(Self.self)", AnalyticsParameterScreenClass: "\(Self.self)"]
                    )
                }
        }
    }
}
