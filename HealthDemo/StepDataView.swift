//
//  DataView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/17.
//

import SwiftUI

struct StepEntry: Identifiable, Codable {
    let id: UUID
    let time: Date
    let steps: Int
}

struct StepDailyRecord: Identifiable {
    let id = UUID()
    let date: String
    let steps: Int
}

struct StepDataView: View {
    @AppStorage("stepData") private var stepRawData: String = ""
    @State private var stepList: [StepEntry] = []

    @State private var inputSteps = ""
    @State private var inputTime = Date()

    // MARK: - 日期格式
    var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }

    var shortDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MM/dd"
        return f
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("运动数据")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                stepProgressCard
                stepDetailCard
                stepInputSection
                stepLogList
                stepTrendCard
                stepAdviceCard
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            loadStepData()
        }
    }
    
    // 步数 -> 距离（单位：公里）
    // 通常 1 步 ≈ 0.00075 公里（换算步幅约 75cm）
    var todayDistance: Double {
        Double(todayTotal) * 0.00075
    }

    // 步数 -> 消耗卡路里（单位：千卡）
    // 约：1,000 步 ≈ 30~50 卡，取中值
    var todayCalories: Int {
        Int(Double(todayTotal) / 1000.0 * 40.0)
    }

    // 强度占比（假设超过 6000 步的部分为中高强度）
    var intensityPercent: Int {
        guard todayTotal > 0 else { return 0 } // ✅ 保护除以 0
        let intenseSteps = max(todayTotal - 6000, 0)
        return min(Int(Double(intenseSteps) / Double(todayTotal) * 100), 100)
    }
    
    var stepDetailCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("运动数据分析")
                .fontWeight(.bold)

            HStack(spacing: 20) {
                dataBlock(title: "距离", value: String(format: "%.1f", todayDistance), unit: "公里")
                dataBlock(title: "卡路里", value: "\(todayCalories)", unit: "千卡")
                dataBlock(title: "强度", value: "\(intensityPercent)%", unit: "中高强度")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    func dataBlock(title: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(unit)
                .font(.caption)
                .foregroundColor(.gray)
            Text(title)
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 核心逻辑
    var todayEntries: [StepEntry] {
        let calendar = Calendar.current
        return stepList.filter { calendar.isDateInToday($0.time) }
    }

    var todayTotal: Int {
        todayEntries.reduce(0) { $0 + $1.steps }
    }

    var mockSteps: [StepDailyRecord] = [
        .init(date: "07/11", steps: 3500),
        .init(date: "07/12", steps: 4200),
        .init(date: "07/13", steps: 1500),
        .init(date: "07/14", steps: 9000),
        .init(date: "07/15", steps: 6700),
        .init(date: "07/16", steps: 4900)
    ]

    var allStepRecords: [StepDailyRecord] {
        var records = mockSteps
        let today = shortDateFormatter.string(from: Date())
        records.append(StepDailyRecord(date: today, steps: todayTotal))
        return records
    }

    // MARK: - 保存与加载
    func addStepEntry() {
        guard let steps = Int(inputSteps), steps > 0 else { return }
        let newEntry = StepEntry(id: UUID(), time: inputTime, steps: steps)
        stepList.append(newEntry)
        saveStepData()
        inputSteps = ""
    }

    func saveStepData() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(stepList),
           let json = String(data: data, encoding: .utf8) {
            stepRawData = json
        }
    }

    func loadStepData() {
        let decoder = JSONDecoder()
        if let data = stepRawData.data(using: .utf8),
           let decoded = try? decoder.decode([StepEntry].self, from: data) {
            stepList = decoded
        }
    }

    // MARK: - UI 模块

    var stepInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("添加步数记录")
                .font(.headline)

            HStack(spacing: 12) {
                TextField("步数", text: $inputSteps)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

                DatePicker("", selection: $inputTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()

                Button(action: addStepEntry) {
                    HStack {
                        Image(systemName: "plus")
                        Text("添加")
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    var stepLogList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日记录（总 \(todayTotal) 步）")
                .fontWeight(.bold)

            ForEach(todayEntries) { entry in
                HStack {
                    Text(timeFormatter.string(from: entry.time))
                    Spacer()
                    Text("\(entry.steps) 步")
                        .foregroundColor(.green)
                }
                .font(.footnote)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    var stepProgressCard: some View {
        let target = 8000.0
        let percent = min(Double(todayTotal) / target, 1.0)

        return HStack {
            ZStack {
                Circle()
                    .trim(from: 0, to: percent)
                    .stroke(Color.green, lineWidth: 8)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80, height: 80)
                Text("\(Int(percent * 100))%")
                    .font(.headline)
            }

            VStack(alignment: .leading) {
                Text("今日步数")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(todayTotal) / 8000 步")
                    .font(.headline)
                Text(percent >= 1 ? "目标完成！" : "再走一走吧~")
                    .font(.caption2)
                    .foregroundColor(percent >= 1 ? .green : .blue)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    var stepTrendCard: some View {
        VStack(alignment: .leading) {
            Text("近7天步数趋势")
                .fontWeight(.bold)

            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(allStepRecords) { record in
                        VStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(record.steps >= 8000 ? Color.green : Color.blue)
                                .frame(width: 20, height: CGFloat(record.steps) / 40)
                            Text(record.date)
                                .font(.caption2)
                                .frame(width: 40)
                                .multilineTextAlignment(.center)
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

    var stepAdviceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI 建议")
                .fontWeight(.bold)

            Text(generateStepAdvice())
                .font(.footnote)
                .padding(10)
                .background(Color.green.opacity(0.05))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    func generateStepAdvice() -> String {
        if todayTotal == 0 {
            return "今日尚未记录步数，建议安排适量活动，有助于提高代谢。"
        } else if todayTotal < 4000 {
            return "今日步数偏少（\(todayTotal) 步），建议增加中低强度运动，如快走或慢跑。"
        } else if todayTotal >= 8000 {
            return "👏 恭喜！今日已完成目标步数（\(todayTotal) 步），继续保持健康节奏！"
        } else {
            return "步数进展不错（已走 \(todayTotal) 步），建议继续每小时站起来活动 5 分钟。"
        }
    }
}
