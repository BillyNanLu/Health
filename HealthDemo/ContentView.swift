//
//  ContentView.swift
//  HealthDemo
//
//  Created by Nan Lu on 2025/7/17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首页")
                }
            
            DataHomeView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("数据")
                }
            
            ReminderView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("提醒")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("我的")
                }
        }
    }
}


#Preview {
    ContentView()
}
