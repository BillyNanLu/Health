//
//  EditProfileView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/18.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userPhone") var userPhone: String = ""
    @AppStorage("userAvatarImageData") var userAvatarImageData: Data?
    @AppStorage("userPassword") var userPassword: String = ""

    @Environment(\.presentationMode) var presentationMode

    @State private var nameInput: String = ""
    @State private var phoneInput: String = ""
    @State private var passwordInput: String = ""
    @State private var selectedImageData: Data?
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("编辑资料")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                // MARK: 上传头像
                VStack(spacing: 8) {
                    if let imageData = selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("选择头像图片")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }

                // MARK: 昵称
                VStack(alignment: .leading, spacing: 6) {
                    Text("昵称").font(.caption).foregroundColor(.gray)
                    TextField("请输入昵称", text: $nameInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // MARK: 手机号
                VStack(alignment: .leading, spacing: 6) {
                    Text("手机号").font(.caption).foregroundColor(.gray)
                    TextField("请输入手机号", text: $phoneInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // MARK: 设置密码
                VStack(alignment: .leading, spacing: 6) {
                    Text("设置密码").font(.caption).foregroundColor(.gray)
                    SecureField("请输入新密码", text: $passwordInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // MARK: 保存按钮
                Button(action: {
                    userName = nameInput
                    userPhone = phoneInput
                    if !passwordInput.isEmpty {
                        userPassword = passwordInput
                    }
                    if let imageData = selectedImageData {
                        userAvatarImageData = imageData
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("保存")
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .onAppear {
                nameInput = userName
                phoneInput = userPhone
                passwordInput = userPassword
                selectedImageData = userAvatarImageData
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
