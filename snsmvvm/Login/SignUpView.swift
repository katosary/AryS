//
//  SignUpView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/17.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var address = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // ▼ 追加：利用規約の同意状態
    @State private var isAgreedToTerms = false
    
    @State private var errorMessage = ""
    @State private var isLoading = false

    // パスワードのバリデーション（英数字を含み、8文字以上）＆確認用の一致
    var isPasswordValid: Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return predicate.evaluate(with: password) && password == confirmPassword
    }
    
    // 全ての必須項目が入力されているか ＋ 利用規約に同意しているか
    var isFormValid: Bool {
        return !name.isEmpty && !address.isEmpty && !phone.isEmpty && !email.isEmpty && isPasswordValid && isAgreedToTerms
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("プロフィール情報")) {
                    TextField("氏名", text: $name)
                    TextField("住所", text: $address)
                    TextField("電話番号", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("アカウント情報"), footer: Text("パスワードは半角英字と数字をそれぞれ1文字以上含めた8桁以上で設定してください。")) {
                    TextField("メールアドレス", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("パスワード（英数字8桁以上）", text: $password)
                    SecureField("パスワード（確認用）", text: $confirmPassword)
                }
                
                // ▼ 追加：利用規約の同意セクション
                Section {
                    Toggle(isOn: $isAgreedToTerms) {
                        HStack(spacing: 4) {
                            Text("利用規約")
                                .foregroundColor(.blue)
                                // .onTapGesture { /* TODO: 規約のWebページを表示するシートなどをここに置けます */ }
                            Text("および")
                            Text("プライバシーポリシー")
                                .foregroundColor(.blue)
                            Text("に同意する")
                        }
                        .font(.subheadline)
                    }
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button {
                        isLoading = true
                        errorMessage = ""
                        
                        authManager.signUp(
                            email: email,
                            password: password,
                            name: name,
                            address: address,
                            phone: phone
                        ) { error in
                            isLoading = false
                            if let error = error {
                                errorMessage = error
                            } else {
                                // 登録成功時は画面を閉じる（AuthManagerのリスナーで自動的にメイン画面に切り替わります）
                                dismiss()
                            }
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("新規登録する")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("新規会員登録")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
