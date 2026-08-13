//
//  SavedListView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/13.
//

// SavedPostsView.swift
import SwiftUI

struct SavedListView: View {
    @State private var viewModel = SavedPostsViewModel()
    @Environment(ProfileViewModel.self) var profileViewModel
    
    // 3列グリッドのレイアウト設定
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(viewModel.savedLogs) { log in
                    // プロフィール画面と同様に、タップで詳細（フルスクリーン）へ遷移するNavigationLink
                    NavigationLink {
                        // 💡 既に作成済みのフルスクリーン詳細ビューを流用
                        ProfileCoffeeLogFullscreenView(profileCoffeeLogViewModel: ProfileCoffeeLogViewModel()) // あるいは専用のViewModelを渡す
                    } label: {
                        if let imageUrl = log.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipped()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        } else {
                            Color.gray.opacity(0.3)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
        .navigationTitle("保存済みの投稿")
        .navigationBarTitleDisplayMode(.inline)
    }
}
