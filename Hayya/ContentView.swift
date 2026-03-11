//
//  ContentView.swift
//  Hayya
//
//  Created by Jafar Fathul Haq on 3/10/26.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case today = "Today"
    case dashboard = "Dashboard"
    case together = "Together"
    case alarms = "Alarms"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .today: return "sun.max"
        case .dashboard: return "chart.bar"
        case .together: return "heart"
        case .alarms: return "bell"
        case .settings: return "gearshape"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .today

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .today:
                    TodayTabView()
                case .dashboard:
                    NavigationStack {
                        PersonalDashboardView()
                    }
                case .together:
                    TogetherTabView()
                case .alarms:
                    AlarmTabView()
                case .settings:
                    SettingsTabView()
                }
            }

            // Custom tab bar
            tabBar
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: tab == selectedTab ? "\(tab.icon).fill" : tab.icon)
                            .font(.system(size: 20))
                            .frame(width: 20, height: 20)

                        Text(tab.rawValue)
                            .font(.system(size: 9, weight: tab == selectedTab ? .semibold : .regular))
                    }
                    .foregroundColor(tab == selectedTab ? Color(hex: 0x5B8C6F) : Color(hex: 0x8E8E93))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        tab == selectedTab
                            ? Color(hex: 0xE8F0EB)
                            : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 2)
        .shadow(color: .black.opacity(0.04), radius: 0.5)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

}

#Preview {
    ContentView()
}
