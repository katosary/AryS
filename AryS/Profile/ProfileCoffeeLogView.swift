//
//  ProfileCoffeeLogView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/22.
//

import SwiftUI

struct ProfileCoffeeLogView: View {
    @State var profileCoffeeLogViewModel = ProfileCoffeeLogViewModel()
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(AuthManager.self) var authManager
    
    let totalWidth: CGFloat
    let totalHeight: CGFloat
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(profileCoffeeLogViewModel.logs) { log in
                    NavigationLink(destination: ProfileCoffeeLogFullscreenView(
                        profileCoffeeLogViewModel: profileCoffeeLogViewModel,
                        currentLogId: log.id
                    )) {
                       
                        if let logId = log.id, let uiImage = profileCoffeeLogViewModel.thumbnailImages[logId] {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: totalWidth / 3, height: totalWidth / 3)
                                .clipped()
                        } else {
                            Color.gray.opacity(0.2)
                                .frame(width: totalWidth / 3, height: totalWidth / 3)
                        }
                    }
                }
            }
        }
        .task {
            profileCoffeeLogViewModel.fetchLogs()
        }
    }
}
