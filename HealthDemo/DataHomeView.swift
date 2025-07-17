//
//  DataHomeView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/17.
//

import SwiftUI

struct DataHomeView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题和分页标签
            VStack(alignment: .leading) {
                Text("健康数据")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)

                HStack {
                    ForEach(0..<3) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(tabTitles[index])
                                .fontWeight(selectedTab == index ? .bold : .regular)
                                .foregroundColor(selectedTab == index ? .blue : .gray)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            // 横向分页内容
            TabView(selection: $selectedTab) {
                StepDataView()
                    .tag(0)
                WaterView()
                    .tag(1)
                SleepView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // 横滑，不显示页码圆点
        }
    }

    let tabTitles = ["运动数据", "饮水记录", "睡眠分析"]
}
