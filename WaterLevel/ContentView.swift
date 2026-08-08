//
//  ContentView.swift
//  WaterLevel
//

import SwiftUI

struct ContentView: View {
    @StateObject private var state = AppState()
    private var theme: Theme { state.theme }

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(state: state)

            VStack(alignment: .leading, spacing: 0) {
                header
                ScrollView {
                    Group {
                        switch state.tab {
                        case .dashboard:
                            DashboardView(theme: theme, range: state.range)
                        case .historical:
                            HistoricalView(theme: theme)
                        }
                    }
                    .padding(.horizontal, 36)
                    .padding(.top, 24)
                    .padding(.bottom, 36)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(theme.background)
        .foregroundStyle(theme.text)
        .frame(minWidth: 960, minHeight: 640)
        .background(WindowConfigurator())
        .preferredColorScheme(state.isDark ? .dark : .light)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(state.tab == .dashboard ? "Lake Dashboard" : "Historical Trends")
                    .font(AppFont.heading(22))
                Text(state.tab == .dashboard
                     ? "Real-time water level for Lake Travis, TX"
                     : "Compare water level across years")
                    .font(AppFont.body(13))
                    .foregroundStyle(theme.textMuted(0.5))
            }
            Spacer()
            if state.tab == .dashboard {
                FlatSegmentedControl(
                    options: RangeOption.allCases,
                    label: { $0.rawValue },
                    selection: $state.range,
                    theme: theme,
                    fontSize: 12
                )
            }
        }
        .padding(.horizontal, 36)
        .padding(.top, 30)
        .padding(.bottom, 16)
        .overlay(alignment: .bottom) {
            Rectangle().fill(theme.divider).frame(height: 2)
        }
    }
}

#Preview {
    ContentView()
}
