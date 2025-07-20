//
//  DashboardView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/17.
//

import SwiftUI

struct DashboardView: View {
    // MARK: - 数据存储接入
    @AppStorage("stepData") private var stepRawData: String = ""
    @AppStorage("waterData") private var waterRawData: String = ""
    @AppStorage("sleepStartTime") private var sleepStartRaw: String = ""
    @AppStorage("sleepEndTime") private var sleepEndRaw: String = ""

    @State private var todaySteps = 0
    @State private var todayWater = 0
    @State private var todaySleep = 0.0 // 小时数

    private let stepGoal = 8000
    private let waterGoal = 2000
    private let sleepGoal = 8.0

    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            Text("健康仪表盘")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

            welcomeCard
                .padding(.horizontal)
                .padding(.top, 10)

            todayGoalCard
                .padding(.horizontal)
                .padding(.top, 10)

            healthDynamicCard
                .padding(.horizontal)
                .padding(.top, 10)

            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            loadStepData()
            loadWaterData()
            loadSleepData()
        }
    }

    // MARK: - 欢迎卡片
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

    // MARK: - 今日目标卡片
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

            GoalItemView(
                icon: "👟",
                title: "步数",
                value: "\(todaySteps) / \(stepGoal)",
                percent: percent(todaySteps, of: stepGoal)
            )

            GoalItemView(
                icon: "💧",
                title: "饮水",
                value: "\(todayWater) / \(waterGoal)ml",
                percent: percent(todayWater, of: waterGoal)
            )

            GoalItemView(
                icon: "😴",
                title: "睡眠",
                value: String(format: "%.1f / %.0f小时", todaySleep, sleepGoal),
                percent: min(todaySleep / sleepGoal, 1.0)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - 健康动态卡片
    var healthDynamicCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("健康动态")
                .fontWeight(.bold)

            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("今日还需饮水 \(max(waterGoal - todayWater, 0))ml")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("步数剩余 \(max(stepGoal - todaySteps, 0)) 步")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

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

            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - 工具方法
    func percent(_ value: Int, of total: Int) -> Double {
        min(Double(value) / Double(total), 1.0)
    }

    func loadStepData() {
        struct StepEntry: Codable { let time: Date; let steps: Int }

        let decoder = JSONDecoder()
        if let data = stepRawData.data(using: .utf8),
           let decoded = try? decoder.decode([StepEntry].self, from: data) {
            todaySteps = decoded.filter { Calendar.current.isDateInToday($0.time) }
                                .reduce(0) { $0 + $1.steps }
        }
    }

    func loadWaterData() {
        struct WaterEntry: Codable { let time: Date; let amount: Int }

        let decoder = JSONDecoder()
        if let data = waterRawData.data(using: .utf8),
           let decoded = try? decoder.decode([WaterEntry].self, from: data) {
            todayWater = decoded.filter { Calendar.current.isDateInToday($0.time) }
                                .reduce(0) { $0 + $1.amount }
        }
    }

    func loadSleepData() {
        guard let start = dateFormatter.date(from: sleepStartRaw),
              let end = dateFormatter.date(from: sleepEndRaw) else {
            todaySleep = 0
            return
        }
        // 🕛 若起床时间早于入睡时间 → 自动加一天
        var correctedEnd = end
        if end < start {
            correctedEnd = Calendar.current.date(byAdding: .day, value: 1, to: end) ?? end
        }
        
        let interval = correctedEnd.timeIntervalSince(start)
        todaySleep = max(interval / 3600, 0)
    }
}

// MARK: - 子组件：目标项
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
