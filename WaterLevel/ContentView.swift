//
//  ContentView.swift
//  WaterLevel
//

import SwiftUI

struct ContentView: View {
    @StateObject private var state = AppState()
    private var theme: Theme { state.theme }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    DashboardView(theme: theme, range: state.range)

                    // Annual summary table
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ANNUAL SUMMARY")
                            .font(AppFont.heading(18))
                        Text("Year-over-year statistics")
                            .font(AppFont.body(13))
                            .foregroundStyle(theme.textMuted(0.5))
                    }
                    .padding(.top, 12)

                    HistoricalTableView(theme: theme)
                }
                .padding(.horizontal, 36)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            footer
        }
        .background(theme.background)
        .foregroundStyle(theme.text)
        .frame(minWidth: 860, minHeight: 640)
        .background(WindowConfigurator())
        .preferredColorScheme(state.isDark ? .dark : .light)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("TRAVIS LEVEL")
                    .font(AppFont.heading(16))
                Text("WATER LEVEL MONITOR")
                    .font(AppFont.body(10.5, weight: .semibold))
                    .tracking(0.4)
                    .foregroundStyle(theme.textMuted(0.45))
            }
            Spacer()
            FlatSegmentedControl(
                options: RangeOption.allCases,
                label: { $0.rawValue },
                selection: $state.range,
                theme: theme,
                fontSize: 12
            )
        }
        .padding(.horizontal, 36)
        .padding(.top, 30)
        .padding(.bottom, 16)
        .overlay(alignment: .bottom) {
            Rectangle().fill(theme.divider).frame(height: 2)
        }
    }

    private var footer: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Rectangle()
                    .fill(theme.accent)
                    .frame(width: 6, height: 6)
                Text("LIVE · SYNCED 2 MIN AGO")
                    .font(AppFont.body(11.5, weight: .bold))
                    .foregroundStyle(theme.accent)
            }
            Text("LAKE TRAVIS, TX")
                .font(AppFont.body(10.5, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(theme.textMuted(0.5))
            Spacer()
            FlatSegmentedControl(
                options: [false, true],
                label: { $0 ? "DARK" : "LIGHT" },
                selection: $state.isDark,
                theme: theme,
                fontSize: 11
            )
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 14)
        .overlay(alignment: .top) {
            Rectangle().fill(theme.divider).frame(height: 2)
        }
    }
}

#Preview {
    ContentView()
}
