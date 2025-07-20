//
//  ProfileView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/17.
//

import SwiftUI

struct ProfileView: View {
    // MARK: 用户信息
    @AppStorage("userName") var userName: String = "曜霖筑序途"
    @AppStorage("userPhone") var userPhone: String = "188****8888"
    @AppStorage("userAvatar") var userAvatar: String = "person.circle.fill"
    @AppStorage("userAvatarImageData") var userAvatarImageData: Data?
    
    // MARK: 数据存储
    @AppStorage("stepData") private var stepRawData: String = ""
    @AppStorage("waterData") private var waterRawData: String = ""
    @AppStorage("sleepStartRaw") var sleepStartRaw: String = ""
    @AppStorage("sleepEndRaw") var sleepEndRaw: String = ""

    // MARK: 状态变量
    @State private var totalWeeklySteps = 0
    @State private var totalWeeklyWater = 0
    @State private var estimatedWeeklySleep: Double = 0.0

    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    summaryCard
                    settingsList
                    logoutButton
                }
                .padding()
                .onAppear {
                    loadWeeklySummary()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }

    // MARK: Header
    var headerSection: some View {
        HStack(spacing: 16) {
            if let avatarData = userAvatarImageData,
               let uiImage = UIImage(data: avatarData) {
                // ✅ 用户上传了头像，优先显示图片
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .shadow(radius: 2)
            } else {
                // ❌ 否则显示默认 SF Symbol 图标
                Image(systemName: userAvatar)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.blue)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(userName)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(userPhone)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // MARK: 健康摘要卡片（真实数据）
    var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周健康摘要")
                .fontWeight(.bold)

            HStack {
                summaryItem(icon: "figure.walk", label: "步数", value: "\(totalWeeklySteps)")
                summaryItem(icon: "drop.fill", label: "饮水", value: "\(totalWeeklyWater)ml")
                summaryItem(icon: "bed.double.fill", label: "睡眠", value: String(format: "%.1f", estimatedWeeklySleep) + "h")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    func summaryItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: 设置项列表
    var settingsList: some View {
        VStack(spacing: 1) {
            NavigationLink(destination: EditProfileView()) {
                settingItem(icon: "pencil", title: "编辑资料")
            }
            NavigationLink(destination: ChangePasswordView()) {
                settingItem(icon: "key.fill", title: "修改密码")
            }
            settingItem(icon: "lock.shield", title: "隐私政策")
            settingItem(icon: "info.circle", title: "关于我们")
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    func settingItem(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
    }

    var logoutButton: some View {
        Button(action: {
            // 清除数据或跳转登录页
        }) {
            Text("退出登录")
                .foregroundColor(.red)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
        }
        .padding(.top, 20)
    }

    // MARK: 加载统计
    func loadWeeklySummary() {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startOfWeek = calendar.date(byAdding: .day, value: -6, to: startOfToday) else { return }

        // 步数
        if let data = stepRawData.data(using: .utf8),
           let list = try? JSONDecoder().decode([StepEntry].self, from: data) {
            totalWeeklySteps = list.filter {
                $0.time >= startOfWeek && $0.time <= now
            }.reduce(0) { $0 + $1.steps }
        }

        // 饮水
        if let data = waterRawData.data(using: .utf8),
           let list = try? JSONDecoder().decode([WaterEntry].self, from: data) {
            totalWeeklyWater = list.filter {
                $0.time >= startOfWeek && $0.time <= now
            }.reduce(0) { $0 + $1.amount }
        }

        // 睡眠（用今日时长 * 7）
        if let start = dateFormatter.date(from: sleepStartRaw),
           let end = dateFormatter.date(from: sleepEndRaw) {
            var correctedEnd = end
            if end < start {
                correctedEnd = Calendar.current.date(byAdding: .day, value: 1, to: end) ?? end
            }
            let hours = correctedEnd.timeIntervalSince(start) / 3600
            estimatedWeeklySleep = (hours * 7).rounded(toPlaces: 1)
        } else {
            estimatedWeeklySleep = 0
        }
    }
}
