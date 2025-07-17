//
//  WaterView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/18.
//

import SwiftUI

struct WaterEntry: Identifiable, Codable {
    let id: UUID
    let time: Date
    let amount: Int
}

struct WaterDailyRecord: Identifiable {
    let id = UUID()
    let date: String
    let amount: Int
}

struct WaterView: View {
    // 数据持久化
    @AppStorage("waterData") private var waterRawData: String = ""
    @State private var waterList: [WaterEntry] = []

    // 用户输入
    @State private var inputAmount = ""
    @State private var inputTime = Date()

    // 日期格式器
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

    // 当前日期数据
    var todayEntries: [WaterEntry] {
        let calendar = Calendar.current
        return waterList.filter { calendar.isDateInToday($0.time) }
    }

    var todayTotal: Int {
        todayEntries.reduce(0) { $0 + $1.amount }
    }

    // 模拟历史数据 + 今天
    var mockWater: [WaterDailyRecord] = [
        .init(date: "07/11", amount: 1200),
        .init(date: "07/12", amount: 1800),
        .init(date: "07/13", amount: 1500),
        .init(date: "07/14", amount: 600),
        .init(date: "07/15", amount: 2100),
        .init(date: "07/16", amount: 1300)
    ]

    var allWaterRecords: [WaterDailyRecord] {
        var records = mockWater
        let today = shortDateFormatter.string(from: Date())
        records.append(WaterDailyRecord(date: today, amount: todayTotal))
        return records
    }

    // 页面主体
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("饮水记录")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                waterProgressCard
                waterInputSection
                waterLogList
                waterTrendCard
                waterAdviceCard
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            loadWaterData()
        }
    }

    // MARK: - UI 模块

    var waterInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("添加饮水记录")
                .font(.headline)

            HStack(spacing: 12) {
                TextField("水量 (ml)", text: $inputAmount)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

                DatePicker("", selection: $inputTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()

                Button(action: addWaterEntry) {
                    HStack {
                        Image(systemName: "plus")
                        Text("添加")
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.blue)
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

    func addWaterEntry() {
        guard let amount = Int(inputAmount), amount > 0 else { return }
        let newEntry = WaterEntry(id: UUID(), time: inputTime, amount: amount)
        waterList.append(newEntry)
        saveWaterData()
        inputAmount = ""
    }

    func saveWaterData() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(waterList),
           let json = String(data: data, encoding: .utf8) {
            waterRawData = json
        }
    }

    func loadWaterData() {
        let decoder = JSONDecoder()
        if let data = waterRawData.data(using: .utf8),
           let decoded = try? decoder.decode([WaterEntry].self, from: data) {
            waterList = decoded
        }
    }

    var waterLogList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日记录（总 \(todayTotal) ml）")
                .fontWeight(.bold)

            ForEach(todayEntries) { log in
                HStack {
                    Text(timeFormatter.string(from: log.time))
                    Spacer()
                    Text("\(log.amount) ml")
                        .foregroundColor(.blue)
                }
                .font(.footnote)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    var waterProgressCard: some View {
        let target = 2000.0
        let percent = min(Double(todayTotal) / target, 1.0)

        return HStack {
            ZStack {
                Circle()
                    .trim(from: 0, to: percent)
                    .stroke(Color.blue, lineWidth: 8)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80, height: 80)
                Text("\(Int(percent * 100))%")
                    .font(.headline)
            }

            VStack(alignment: .leading) {
                Text("今日已饮水量")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(todayTotal) / 2000 ml")
                    .font(.headline)
                Text(percent >= 1 ? "目标达成！" : "继续补水~")
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

    var waterTrendCard: some View {
        VStack(alignment: .leading) {
            Text("近7天饮水趋势")
                .fontWeight(.bold)

            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(allWaterRecords) { record in
                        VStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(record.amount >= 2000 ? Color.green : Color.blue)
                                .frame(width: 20, height: CGFloat(record.amount) / 10)

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

    var waterAdviceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI 建议")
                .fontWeight(.bold)

            Text(generateWaterAdvice())
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

    func generateWaterAdvice() -> String {
        if todayTotal == 0 {
            return "今日尚未饮水，请尽快补充水分，维持身体代谢与专注力。"
        }

        let morningStart = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date())!
        let morningEnd = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!

        let hasMorningDrink = todayEntries.contains { $0.time >= morningStart && $0.time <= morningEnd }

        if todayTotal < 1000 {
            return "今日饮水量偏少（当前 \(todayTotal) ml），建议适量补水，成人每日推荐摄入约 2,000 ml。"
        } else if !hasMorningDrink {
            return "上午未检测到饮水记录，建议早起后尽早补充水分，有助于启动身体代谢。"
        } else if todayTotal >= 2000 {
            return "👏 喝水目标已达成（\(todayTotal) ml），请继续保持良好的饮水习惯！"
        } else {
            return "饮水节奏良好（已喝 \(todayTotal) ml），请保持每小时补水 200 ml 的频率。"
        }
    }
}
