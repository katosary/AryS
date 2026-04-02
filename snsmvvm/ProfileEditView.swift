//
//  ProfileEditView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/28.
//

import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var viewModel: ViewModel 
    
    var body: some View {
        NavigationStack{
            Form{
                HStack{
                    Text("ユーザー名：")
                    TextField("ユーザー名を入力してください",text: $viewModel.userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                HStack{
                    Text("お気に入りのコーヒー：")
                    TextField("お気に入りのコーヒーを入力してください",text: $viewModel.favoriteCoffee)
                    
                }
            }
            .navigationTitle("プロフィール編集")
            //            .onAppear{
            //                viewModel.editingUser = viewModel.user
            //                viewModel.editingFavoCoffee = viewModel.favoriteCoffee
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // ViewModelの更新関数を呼ぶ
                        viewModel.updateUser()
                        //viewModel.updatePost(targetPost: post)
                        dismiss()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

