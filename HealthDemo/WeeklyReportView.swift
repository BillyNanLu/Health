//
//  WeeklyReportView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/18.
//

import SwiftUI

// 周数据结构
struct WeeklyHealthData {
    let weekLabel: String
    let dateRange: String
    let dailySteps: [Int]
    let dailyWater: [Int]
    let dailySleep: [Double]
    
    var totalSteps: Int {
        dailySteps.reduce(0, +)
    }
    var averageWater: Int {
        dailyWater.reduce(0, +) / dailyWater.count
    }
    var averageSleep: Double {
        (dailySleep.reduce(0, +) / Double(dailySleep.count)).rounded(toPlaces: 1)
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

struct WeeklyReportView: View {
    @State private var selectedWeek = 0 // 0: 上周，1: 上上周
    
    let fakeData: [WeeklyHealthData] = [
        WeeklyHealthData(
            weekLabel: "2025年第28周",
            dateRange: "07.07 - 07.13",
            dailySteps: [8600, 7400, 9200, 10300, 9800, 7500, 7900],
            dailyWater: [2000, 1800, 1700, 1900, 2100, 1600, 1800],
            dailySleep: [6.5, 7.0, 6.2, 7.5, 6.8, 5.9, 7.1]
        ),
        WeeklyHealthData(
            weekLabel: "2025年第27周",
            dateRange: "06.30 - 07.06",
            dailySteps: [6000, 5000, 7000, 7200, 6500, 4000, 5200],
            dailyWater: [1500, 1600, 1400, 1700, 1300, 1200, 1500],
            dailySleep: [5.5, 6.0, 5.8, 6.2, 6.5, 5.3, 6.0]
        )
    ]
    
    let weekdays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    var currentData: WeeklyHealthData {
        fakeData[selectedWeek]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                stepSection
                waterSection
                sleepSection
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: Header
    var headerSection: some View {
        HStack {
            Text("健康仪表盘")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
            
            Spacer()
            Button(action: {
                if selectedWeek < fakeData.count - 1 { selectedWeek += 1 }
            }) {
                Image(systemName: "chevron.left")
            }
            .disabled(selectedWeek == fakeData.count - 1)
            
            Spacer()
            VStack(spacing: 4) {
                Text(currentData.weekLabel).font(.headline)
                Text(currentData.dateRange).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: {
                if selectedWeek > 0 { selectedWeek -= 1 }
            }) {
                Image(systemName: "chevron.right")
            }
            .disabled(selectedWeek == 0)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // MARK: 步数
    var stepSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏃 步数报告").fontWeight(.bold)
            Text("总步数：\(currentData.totalSteps) 步").font(.headline)
            Text(currentData.totalSteps >= 56000 ? "步数达标，继续保持活力！" : "本周活动量略少，建议适当锻炼～")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(0..<7, id: \.self) { i in
                    VStack {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 100)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(height: CGFloat(currentData.dailySteps[i]) / 80)
                        }
                        .frame(width: 24)
                        Text(weekdays[i]).font(.caption2)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // MARK: 饮水
    var waterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💧 饮水报告").fontWeight(.bold)
            Text("平均每日饮水：\(currentData.averageWater) ml").font(.headline)
            Text(currentData.averageWater >= 1800 ? "饮水量不错，继续维持补水节奏" : "补水略少，建议每天不少于 2000ml")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(0..<7, id: \.self) { i in
                    VStack {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 100)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(height: CGFloat(currentData.dailyWater[i]) / 10)
                        }
                        .frame(width: 16)
                        Text(weekdays[i]).font(.caption2)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // MARK: 睡眠
    var sleepSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("😴 睡眠报告").fontWeight(.bold)
            Text("平均每日睡眠：\(currentData.averageSleep, specifier: "%.1f") 小时").font(.headline)
            Text(currentData.averageSleep >= 7.0 ? "睡眠充足，有助于恢复体力" : "建议每晚睡满 7 小时")
                .font(.caption)
                .foregroundColor(.gray)
            
            ForEach(0..<7, id: \.self) { i in
                HStack {
                    Text(weekdays[i]).font(.caption2)
                    Spacer()
                    Text("\(currentData.dailySleep[i], specifier: "%.1f") 小时")
                        .foregroundColor(currentData.dailySleep[i] >= 7 ? .green : .blue)
                        .font(.footnote)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
