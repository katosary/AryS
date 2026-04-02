//
//  ProfileView.swift
//  snsmvvm
//
//  Created by katoso on 2026/03/22.
//

import SwiftUI

struct ProfileView: View {
    @State var viewModel = ViewModel() 
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 15) { //これから並べるVStackの中のものを先頭寄せにして並べるものの間に15のスペースを作る
                    
                    // 1. ヘッダー（アイコンと数字）
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()//これがなければ下の枠の中に上の画像が小さくあるだけになる。枠の大きさに合わせて上の画像を大きくするために必要になる。
                            .frame(width: 80, height: 80)//画像を入れるための枠の大きさを指定している
                            .padding(20)
                            .foregroundColor(.gray)
                        
                        VStack{
                            HStack{
                                Text(viewModel.userName)
                                //                                Text("ユーザー名")
                                    .font(.headline)
                                // プロフィール編集ボタン
                                Button{
                                    viewModel.isProfileEditSheet = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .frame(width: 30, height: 30)
                                        .background(Color(.systemGray6))
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)//horizontalは上下にスペースは作らず、左右だけに作りだす。
                                
                            }
                            HStack(spacing: 2){
                                viewModel.profileStat(count: "12", label: "投稿")
                                viewModel.profileStat(count: "150", label: "フォロワー")
                            }
                        }
                    }
                    VStack{
                        HStack{
                            Text("お気に入りのコーヒー：")
                            Text(viewModel.favoriteCoffee)
                        }
                        .padding(30)
                    }
                    .padding(.top)
                }
                .navigationTitle("プロフィール")
                .navigationBarTitleDisplayMode(.inline)
            }
            .sheet(isPresented: $viewModel.isProfileEditSheet){
                ProfileEditView(viewModel: $viewModel)
            }
        }
    }
}
