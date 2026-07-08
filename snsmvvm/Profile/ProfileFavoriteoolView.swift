//
//  ProFavoToolView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/22.
//

import SwiftUI

struct ProFavoToolView: View {
    var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            
            if hasDripTools {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "ドリップ用品")
                    displayRow(label: "ドリッパー", value: profileViewModel.dripper)
                    displayRow(label: "ペーパー", value: profileViewModel.paperFilter)
                    displayRow(label: "ケトル", value: profileViewModel.kettle)
                    displayRow(label: "サーバー", value: profileViewModel.server)
                    displayRow(label: "スケール", value: profileViewModel.scale)
                }
            }
            
            if hasGrinderTools {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "粉砕器具")
                    displayRow(label: "ミル", value: profileViewModel.mill)
                    displayRow(label: "グラインダー", value: profileViewModel.grinder)
                }
            }
            
            if hasOtherTools {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "その他")
                    displayRow(label: "エスプレッソ", value: profileViewModel.espressoMachine)
                    displayRow(label: "プレス", value: profileViewModel.frenchPress)
                }
            }
            
            if !hasDripTools && !hasGrinderTools && !hasOtherTools {
                Text("お気に入りの道具がまだ登録されていません。")
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .padding(20) // 💡内側の余白を統一
        .frame(maxWidth: .infinity) // 💡横幅いっぱいに広げる
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
    private func displayRow(label: String, value: String) -> some View {
        if !value.isEmpty {
            HStack(alignment: .top) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 110, alignment: .leading) // 💡110で統一
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .bold()
                Spacer()
            }
            Divider()
        }
    }
    
    private var hasDripTools: Bool { !profileViewModel.dripper.isEmpty || !profileViewModel.paperFilter.isEmpty || !profileViewModel.kettle.isEmpty || !profileViewModel.server.isEmpty || !profileViewModel.scale.isEmpty }
    private var hasGrinderTools: Bool { !profileViewModel.mill.isEmpty || !profileViewModel.grinder.isEmpty }
    private var hasOtherTools: Bool { !profileViewModel.espressoMachine.isEmpty || !profileViewModel.frenchPress.isEmpty }
}

