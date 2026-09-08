//
//  ProfileTabButton.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct ProfileTabButton: View {
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                
                Rectangle()
                    .fill(selectedTab == index ? Color.white : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
    }
}
