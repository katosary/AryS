//
//  PostViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

//ViewModel
import Observation
import SwiftUI

@Observable
class ViewModel {
    var posts: [Post] = []//SendMessageViewで入力された内容を保存している配列。　postsはその配列の名前
    var coffeeName: String = ""
    var content: String = ""
    var inputcoffee: String = ""
    var inputcontent: String = ""
    var editingUser: String = ""
    var editingCoffee: String = ""
    var editingFavoCoffee: String = ""
    var editingContent: String = ""
    var iswritingsheet = false
    var isEditSheet: Bool = false
    var isProfileEditSheet: Bool = false
    var rating: Int = 0
    var maxRating = 5
    var editingRating: Int = 0
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    var selectedPost: Post?
    var selectedTab: Int = 0
    
    var user: User = User(userNo: 0, userName: "Anonymous", favoriteCoffee: "")
    var userName: String = ""
    var favoriteCoffee: String = ""
    var userNo: Int = 0
    
    //投稿追加
    func addPost() {
        let newPost = Post(user: user,coffeeName:coffeeName,content: content,rating:rating, createdAt: Date())
        posts.append(newPost)
        coffeeName = ""
        content = ""
    }
    
    //投稿編集ボタン
    func updatePost(targetPost: Post) {
        if let id = posts.firstIndex(where: { $0.id == targetPost.id }) {
            // その場所の内容を、保存しておいた editingText で上書きする
            posts[id].coffeeName = self.editingCoffee
            posts[id].content = self.editingContent
            posts[id].rating = self.editingRating
            clearEditingData()
            self.isEditSheet = false
        }
    }
    
    func clearEditingData() {
        self.editingCoffee = ""
        self.editingContent = ""
        self.editingRating = 0
    }
    
    //投稿削除ボタン
    func deletePost(targetPost: Post) {
        posts.removeAll {$0.id == targetPost.id }
    }
    
    //投稿星評価
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
    
    //ユーザー情報編集
    func updateUser(){
        user = User(
            userNo: userNo,
            userName: userName,
            favoriteCoffee: favoriteCoffee)
    }
    
    //プロフィール数字情報
    func profileStat(count: String, label: String) -> some View {
        VStack {
            Text(count)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity) // 均等に並ぶように幅を広げる
    }
}

//removeAll は「条件に合うものを全部消す」という命令
//firstIndex(where:) は「条件に合うものがどこ（何番目）にあるか教えて」という命令

