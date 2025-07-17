//
//  DataView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/17.
//

import SwiftUI

struct StepDataView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 页面标题
                Text("运动数据")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)

                stepSummaryCard

                stepStatsCard

                stepHeatmapCard

                activityTypeCard

                aiAdviceCard
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // 步数摘要卡片
    var stepSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("6,842")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("今日步数")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("目标: 8,000")
                    Text("85% 完成")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // 运动统计（公里、卡路里、中高强度）
    var stepStatsCard: some View {
        HStack(spacing: 20) {
            statItem(title: "公里", value: "3.2")
            statItem(title: "卡路里", value: "320")
            statItem(title: "中高强度", value: "65%")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    func statItem(title: String, value: String) -> some View {
        VStack {
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    // 步数热力图（模拟分布）
    var stepHeatmapCard: some View {
        VStack(alignment: .leading) {
            Text("步数分布")
                .fontWeight(.bold)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(sampleSteps, id: \.hour) { item in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.color)
                            .frame(height: CGFloat(item.height))
                        Text(item.hour)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // 示例数据
    struct StepHourData {
        let hour: String
        let height: Int
        let color: Color
    }

    let sampleSteps: [StepHourData] = [
        .init(hour: "7-9", height: 30, color: .blue.opacity(0.2)),
        .init(hour: "9-11", height: 50, color: .blue.opacity(0.3)),
        .init(hour: "11-13", height: 20, color: .blue.opacity(0.2)),
        .init(hour: "13-15", height: 10, color: .blue.opacity(0.2)),
        .init(hour: "15-17", height: 80, color: .blue),
        .init(hour: "17-19", height: 40, color: .blue.opacity(0.3)),
        .init(hour: "19-21", height: 60, color: .blue.opacity(0.3)),
    ]
    
    // 运动类型分布
    var activityTypeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("运动类型")
                .fontWeight(.bold)
            HStack(spacing: 20) {
                activityItem(icon: "🚶", title: "步行", percent: "75%")
                activityItem(icon: "🏃", title: "跑步", percent: "15%")
                activityItem(icon: "🚴", title: "骑行", percent: "10%")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    func activityItem(icon: String, title: String, percent: String) -> some View {
        VStack {
            Text(icon)
                .font(.title)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            Text(title).font(.caption)
            Text(percent)
                .font(.footnote)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
    }
    
    // AI建议卡片
    var aiAdviceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI建议")
                .fontWeight(.bold)
            Text("下午3-5点活动较少，建议起身走动或做简单拉伸，有助于提高代谢率。")
                .font(.footnote)
                .foregroundColor(.black)
                .padding(10)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
