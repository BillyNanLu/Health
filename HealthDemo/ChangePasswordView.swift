//
//  ChangePasswordView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/18.
//

import SwiftUI

struct ChangePasswordView: View {
    @AppStorage("userPassword") var userPassword: String = ""
    @Environment(\.presentationMode) var presentationMode

    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var errorMessage: String = ""
    @State private var showSuccessAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("修改密码")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                // MARK: 旧密码
                VStack(alignment: .leading, spacing: 6) {
                    Text("当前密码").font(.caption).foregroundColor(.gray)
                    SecureField("请输入旧密码", text: $oldPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // MARK: 新密码
                VStack(alignment: .leading, spacing: 6) {
                    Text("新密码").font(.caption).foregroundColor(.gray)
                    SecureField("请输入新密码", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // MARK: 确认密码
                VStack(alignment: .leading, spacing: 6) {
                    Text("确认新密码").font(.caption).foregroundColor(.gray)
                    SecureField("再次输入新密码", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // MARK: 错误信息
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                // MARK: 保存按钮
                Button(action: handleChangePassword) {
                    Text("保存修改")
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top)

                Spacer()
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("密码修改成功"),
                message: Text("已成功更新您的密码"),
                dismissButton: .default(Text("确定")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    // MARK: 修改逻辑
    func handleChangePassword() {
        errorMessage = ""

        guard oldPassword == userPassword else {
            errorMessage = "旧密码不正确"
            return
        }

        guard !newPassword.isEmpty else {
            errorMessage = "新密码不能为空"
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "两次输入的新密码不一致"
            return
        }

        userPassword = newPassword
        showSuccessAlert = true
    }
}
