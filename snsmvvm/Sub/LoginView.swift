//
//  LoginView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/03.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @ObservedObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("メールアドレス", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disabled(isLoading)
            
            SecureField("パスワード", text: $password)
                .textFieldStyle(.roundedBorder)
                .disabled(isLoading)
            
            Button(action: {
                isLoading = true
                authManager.registerAndLogin(email: email, password: password) { error in
                    DispatchQueue.main.async {
                        isLoading = false
                        if let error = error {
                            self.errorMessage = error
                        }
                    }
                }
            }) {
                if isLoading { ProgressView() } else { Text("ログイン") }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            
            Text(errorMessage).foregroundColor(.red).font(.caption)
        }
        .padding()
    }
}

#Preview {
    LoginView(authManager: AuthManager())
}
