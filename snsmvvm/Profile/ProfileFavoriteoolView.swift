//
//  ProfileFavoriteToolView.swift
//  snsmvvm
//

import SwiftUI

struct ProfileFavoriteToolView: View {
    var profileViewModel: ProfileViewModel
    
    // User オブジェクトをショートカット参照（コードの可読性アップ）
    private var user: User {
        profileViewModel.user
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            
            if hasDripTools {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "ドリップ用品")
                    displayRow(label: "ドリッパー", value: user.dripper)
                    displayRow(label: "ペーパー", value: user.paperFilter)
                    displayRow(label: "ケトル", value: user.kettle)
                    displayRow(label: "サーバー", value: user.server)
                    displayRow(label: "スケール", value: user.scale)
                }
            }
            
            if hasGrinderTools {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "粉砕器具")
                    displayRow(label: "ミル", value: user.mill)
                    displayRow(label: "グラインダー", value: user.grinder)
                }
            }
            
            if hasOtherTools {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "その他")
                    displayRow(label: "エスプレッソ", value: user.espressoMachine)
                    displayRow(label: "プレス", value: user.frenchPress)
                }
            }
            
            if !hasDripTools && !hasGrinderTools && !hasOtherTools {
                Text("お気に入りの道具がまだ登録されていません。")
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .padding(.top, 5)
    }
    
    @ViewBuilder
    private func displayRow(label: String, value: String?) -> some View {
        // String? 型に対応（nilでなく空文字でもない場合のみ表示）
        if let val = value, !val.trimmingCharacters(in: .whitespaces).isEmpty {
            HStack(alignment: .top) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 110, alignment: .leading)
                Text(val)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .bold()
                Spacer()
            }
            Divider()
        }
    }
    
    // MARK: - 判定用プロパティ（User の String? に対応）
    
    private func isNotEmpty(_ value: String?) -> Bool {
        guard let value = value else { return false }
        return !value.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var hasDripTools: Bool {
        isNotEmpty(user.dripper) || isNotEmpty(user.paperFilter) || isNotEmpty(user.kettle) || isNotEmpty(user.server) || isNotEmpty(user.scale)
    }
    
    private var hasGrinderTools: Bool {
        isNotEmpty(user.mill) || isNotEmpty(user.grinder)
    }
    
    private var hasOtherTools: Bool {
        isNotEmpty(user.espressoMachine) || isNotEmpty(user.frenchPress)
    }
}
