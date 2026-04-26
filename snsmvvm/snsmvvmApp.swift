//
//  snsmvvmApp.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/25.
//

import SwiftUI

@main
struct snsmvvmApp: App {
    @State private var mainVM = ViewModel()
    @State private var profileVM = ProfileViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(mainVM)
                .environment(profileVM)
        }
    }
}
