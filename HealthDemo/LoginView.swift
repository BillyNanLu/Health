//
//  LoginView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/18.
//

import SwiftUI

struct LoginView: View {
    @State private var phoneInput: String = ""
    @State private var passwordInput: String = ""
    @State private var errorMessage: String = ""

    @AppStorage("currentUserPhone") var currentUserPhone: String = ""
    
    @State private var isLoggedIn = false

    var body: some View {
        VStack(spacing: 20) {
            Text("欢迎登录")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 60)

            TextField("请输入手机号", text: $phoneInput)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)

            SecureField("请输入密码", text: $passwordInput)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: login) {
                Text("登录")
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $isLoggedIn) {
            DashboardView() // ✅ 登录成功后显示主页
        }
    }

    // MARK: 登录逻辑
    func login() {
        guard !phoneInput.isEmpty, !passwordInput.isEmpty else {
            errorMessage = "手机号和密码不能为空"
            return
        }

        let passwordKey = "userPassword_\(phoneInput)"
        let storedPassword = UserDefaults.standard.string(forKey: passwordKey) ?? ""

        if passwordInput == storedPassword {
            currentUserPhone = phoneInput
            isLoggedIn = true
        } else {
            errorMessage = "手机号或密码错误"
        }
    }
}
