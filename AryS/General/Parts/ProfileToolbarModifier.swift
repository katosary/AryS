//
//  ProfileToolbarModifier.swift
//  AryS
//
//  Created by katoso on 2026/08/30.
//

import SwiftUI

struct ProfileToolbarModifier: ViewModifier {
    var profileViewModel: ProfileViewModel
    var authManager: AuthManager

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        MenuView()
                            .environment(authManager)
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
                 
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .foregroundColor(.primary)
                        .scaledToFit()
                        .frame(height: 44)
                }
                 
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NotificationView()
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}
