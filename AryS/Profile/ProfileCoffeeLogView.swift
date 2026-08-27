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
                // profileCoffeeLogViewModel.logs が空でないか確認
                ForEach(profileCoffeeLogViewModel.logs) { log in
                    NavigationLink(destination: ProfileCoffeeLogFullscreenView(
                        profileCoffeeLogViewModel: profileCoffeeLogViewModel,
                        currentLogId: log.id
                    )) {
                        if let imageUrlString = log.imageUrl, let url = URL(string: imageUrlString) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: totalWidth / 3, height: totalWidth / 3)
                            .clipped()
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
