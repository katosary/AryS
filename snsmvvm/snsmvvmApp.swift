//
//  snsmvvmApp.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/25.
//

import SwiftUI

@main
struct snsmvvmApp: App {
    @State private var viewModel = ViewModel()
    @State private var profileViewModel = ProfileViewModel()
    @State private var seachViewModel = SearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                .environment(profileViewModel)
                .environment(seachViewModel)
        }
    }
}
