//
//  TrendView.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/17.
//

import SwiftUI

// --- 1. メインの横スクロール画面 ---
struct MatchingView: View {
    @State var matchingViewModel = MatchingViewModel()
    
    var body: some View {
        NavigationStack {
            // 💡 ここで画面全体の背景色を指定
            ZStack {
                Color(.systemBackground).ignoresSafeArea() // 背景をシステム背景色に
                
                Group {
                    if matchingViewModel.isLoading {
                        VStack {
                            ProgressView()
                            Text("コーヒーを淹れています...")
                                .padding()
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 0) {
                                ForEach(matchingViewModel.discoveredProfiles) { profile in
                                    MatchProfileView(profile: profile)
                                        .containerRelativeFrame(.horizontal)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollContentBackground(.hidden) // 💡 ScrollViewのデフォルト背景を消す
                    }
                }
            }
            .task {
                if matchingViewModel.discoveredProfiles.isEmpty {
                    await matchingViewModel.fetchRecommendedProfiles()
                }
            }
        }
    }
}


struct ActionButton: View {
    let icon: String
    let color: Color
    var body: some View {
        Image(systemName: icon)
            .font(.title.bold())
            .foregroundColor(color)
            .frame(width: 60, height: 60)
            .background(Color(.systemBackground)) // 💡 背景をシステム背景色に
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.1), radius: 5) // 影を薄く
    }
}
