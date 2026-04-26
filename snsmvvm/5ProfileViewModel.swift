//
//  5ProfileViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/04/18.
//

import Observation
import SwiftUI
import PhotosUI

@Observable
class ProfileViewModel {
    var user: User = User(userNo: 0, userName: "", selfIntroduction: "", favoriteCoffee: "",probitter: 0, proacidity: 0, probody: 0, proaroma: 0)
    var userName: String = ""
    var selfIntroduction: String = ""
    var favoriteCoffee: String = ""
    var userNo: Int = 0
    var isProfileEditSheet: Bool = false
    var favoriteCoffeeImage: UIImage?
    var profileImage:  UIImage?
    var probitter: Int = 0
    var proacidity: Int = 0
    var probody: Int = 0
    var proaroma: Int = 0
    
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    
    var selectedCoffeeItem : PhotosPickerItem? {
        didSet{ Task { await loadCoffeeImage() }
        }
    }
    var selectedProfileItem : PhotosPickerItem? {
        didSet{ Task { await loadProfileImage() } }
    }
    
    //ユーザー情報編集
    func updateUser(){
        user = User(
            userNo: userNo,
            userName: userName,
            selfIntroduction: selfIntroduction,
            favoriteCoffee: favoriteCoffee,
            probitter: probitter,
            proacidity: proacidity,
            probody: probody,
            proaroma: proaroma
        )
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
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
    
    
    
    @MainActor
    private func loadCoffeeImage() async {
        guard let data = try? await selectedCoffeeItem?.loadTransferable(type: Data.self) else { return }
        favoriteCoffeeImage = UIImage(data: data)
    }
    @MainActor
    private func loadProfileImage() async {
        guard let data = try? await selectedProfileItem?.loadTransferable(type: Data.self) else { return }
        profileImage = UIImage(data: data)
    }
}
