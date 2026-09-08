//
//  StoreLoginViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/09/06.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Observable
class StoreLoginViewModel {
    var email = ""
    var password = ""
    var errorMessage = ""
    var isLoading = false
    
    let brandBackgroundColor = Color(red: 89/255, green: 61/255, blue: 43/255)
    
    func signIn(completion: @escaping () -> Void) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let uid = authResult?.user.uid else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "ユーザー情報の取得に失敗しました。"
                }
                return
            }
            
            // stores コレクションにドキュメントが存在するか（店舗権限があるか）を確認
            Firestore.firestore().collection("stores").document(uid).getDocument { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "店舗情報の確認に失敗しました: \(error.localizedDescription)"
                        try? Auth.auth().signOut()
                        return
                    }
                    
                    if let snapshot = snapshot, snapshot.exists {
                        // 店舗アカウントとして存在確認OK
                        completion()
                    } else {
                        self.errorMessage = "このアカウントは店舗として登録されていません。"
                        try? Auth.auth().signOut()
                    }
                }
            }
        }
    }
}
