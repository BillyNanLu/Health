//
//  DashboardView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/17.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 页面标题
            Text("健康仪表盘")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

            // 欢迎卡片
            welcomeCard
                .padding(.horizontal)
                .padding(.top, 10)

            // 今日目标卡片
            todayGoalCard
                .padding(.horizontal)
                .padding(.top, 10)
            
            // 健康动态卡片
            healthDynamicCard
                .padding(.horizontal)
                .padding(.top, 10)

            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: 欢迎卡片
    var welcomeCard: some View {
        HStack(alignment: .center) {
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text("欢迎回来")
                    .fontWeight(.bold)
                    .font(.body)

                Text("今日健康评分：86")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: 今日目标卡片
    var todayGoalCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("今日目标")
                    .fontWeight(.bold)
                Spacer()
                Text("查看全部")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            GoalItemView(icon: "👟", title: "步数", value: "6,842 / 8,000", percent: 0.85)
            GoalItemView(icon: "💧", title: "饮水", value: "1,200 / 2,000ml", percent: 0.6)
            GoalItemView(icon: "😴", title: "睡眠", value: "7.2 / 8小时", percent: 0.9)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: 实现 healthDynamicCard 
    var healthDynamicCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("健康动态")
                .fontWeight(.bold)

            // 动态项 1
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("今日还需饮水 800ml")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("上次记录：2小时前")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // 动态项 2
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("解锁“晨型人”成就")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("连续7天7点前起床")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            //Spacer(minLength: 0) // 保持高度一致感
        }
        .padding()
        .frame(maxWidth: .infinity) // 🔹 关键：让它和其他卡片一样宽
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: 子组件 - 每项目标
struct GoalItemView: View {
    let icon: String
    let title: String
    let value: String
    let percent: Double

    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(title).font(.caption).foregroundColor(.gray)
                Text(value).font(.headline)
            }

            Spacer()

            ZStack {
                Circle()
                    .trim(from: 0, to: CGFloat(percent))
                    .stroke(Color.blue, lineWidth: 6)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)

                Text("\(Int(percent * 100))%")
                    .font(.caption)
            }
        }
    }
}
