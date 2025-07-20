//
//  SleepView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/17.
//

import SwiftUI

struct SleepView: View {
    // MARK: - 用户录入 & 持久化
    @AppStorage("sleepStartTime") private var sleepStartRaw: String = ""
    @AppStorage("sleepEndTime") private var sleepEndRaw: String = ""

    @State private var sleepStart: Date = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!
    @State private var sleepEnd: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!

    // MARK: - 初始化加载保存数据
    init() {
        if let start = formatter.date(from: sleepStartRaw) {
            _sleepStart = State(initialValue: start)
        }
        if let end = formatter.date(from: sleepEndRaw) {
            _sleepEnd = State(initialValue: end)
        }
    }

    // MARK: - 核心计算属性
    var sleepDuration: Double {
        let interval = sleepEnd.timeIntervalSince(sleepStart)
        return max(interval / 3600, 0) // 小时
    }

    var sleepPercent: Double {
        min(sleepDuration / 8.0, 1.0)
    }

    var deepSleep: Double {
        sleepDuration * 0.4
    }
    var lightSleep: Double {
        sleepDuration * 0.5
    }
    var awake: Double {
        sleepDuration * 0.1
    }

    // MARK: - 历史数据（模拟 + 当天）
    struct SleepRecord: Identifiable {
        let id = UUID()
        let date: String
        let duration: Double
    }

    let mockRecords: [SleepRecord] = [
        .init(date: "07/11", duration: 7.5),
        .init(date: "07/12", duration: 6.8),
        .init(date: "07/13", duration: 8.1),
        .init(date: "07/14", duration: 5.9),
        .init(date: "07/15", duration: 7.3),
        .init(date: "07/16", duration: 6.5)
    ]
    
    var shortDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MM/dd"
        return f
    }

    var allRecords: [SleepRecord] {
        var result = mockRecords
        let today = shortDateFormatter.string(from: Date())
        result.append(SleepRecord(date: today, duration: sleepDuration))
        return result
    }

    // MARK: - 日期格式化器
    var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }

    func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    // MARK: - 页面布局
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("睡眠分析")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                sleepSummaryCard
                sleepStageCard
                sleepChartCard
                sleepTrendCard
                sleepAdviceCard
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: - 卡片模块

    var sleepSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .trim(from: 0, to: sleepPercent)
                        .stroke(Color.blue, lineWidth: 8)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 80)
                    Text("\(Int(sleepPercent * 100))%")
                        .font(.headline)
                }

                VStack(alignment: .leading) {
                    Text("今日睡眠")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f / 8 小时", sleepDuration))
                        .font(.headline)
                    Text(sleepDuration >= 7 ? "睡眠质量良好" : "注意睡眠时间")
                        .font(.caption2)
                        .foregroundColor(sleepDuration >= 7 ? .blue : .orange)
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("入睡时间")
                    .font(.caption)
                DatePicker("", selection: $sleepStart, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .onChange(of: sleepStart) { oldValue, newValue in
                                sleepStartRaw = formatter.string(from: newValue)
                            }

                Text("起床时间")
                    .font(.caption)
                DatePicker("", selection: $sleepEnd, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .onChange(of: sleepStart) { oldValue, newValue in
                                sleepStartRaw = formatter.string(from: newValue)
                            }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    var sleepStageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("睡眠阶段")
                .fontWeight(.bold)

            HStack {
                stageBlock(color: .blue, title: "深睡", duration: "\(String(format: "%.1f", deepSleep))h")
                stageBlock(color: .purple, title: "浅睡", duration: "\(String(format: "%.1f", lightSleep))h")
                stageBlock(color: .gray, title: "清醒", duration: "\(String(format: "%.1f", awake))h")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    func stageBlock(color: Color, title: String, duration: String) -> some View {
        VStack {
            Circle()
                .fill(color.opacity(0.4))
                .frame(width: 40, height: 40)
            Text(title).font(.caption)
            Text(duration).font(.footnote).fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
    }

    var sleepChartCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("睡眠趋势")
                .fontWeight(.bold)

            let unit: CGFloat = 40
            let deepW = CGFloat(deepSleep) * unit
            let lightW = CGFloat(lightSleep) * unit
            let awakeW = CGFloat(awake) * unit

            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.blue)
                    .frame(width: deepW, height: 16)
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.purple)
                    .frame(width: lightW, height: 16)
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: awakeW, height: 16)
            }

            HStack {
                Text(formattedTime(sleepStart))
                Spacer()
                Text(formattedTime(sleepEnd))
            }
            .font(.caption2)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    var sleepAdviceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI建议")
                .fontWeight(.bold)
            Text("建议每天保持固定的作息时间，避免熬夜，有助于提高深睡比例并改善睡眠质量。")
                .font(.footnote)
                .padding(10)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    var sleepTrendCard: some View {
        VStack(alignment: .leading) {
            Text("近7天睡眠趋势")
                .fontWeight(.bold)

            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(allRecords) { record in
                        VStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: 20, height: CGFloat(record.duration) * 20)
                            Text(record.date)
                                .font(.caption2)
                                .frame(width: 40)
                        }
                    }
                }
                .padding(.top)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
