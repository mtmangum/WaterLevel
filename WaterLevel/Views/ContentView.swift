//
//  ContentView.swift
//  WaterLevel
//

import SwiftUI

struct ContentView: View {
    @StateObject private var state = AppState()
    private var theme: Theme { state.theme }

    @State private var showAnnualSummary = false

    var body: some View {
        VStack(spacing: 0) {
            header
            DashboardView(theme: theme)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 36)
                .padding(.top, 20)
                .padding(.bottom, 20)
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
                Text("LAKE TRAVIS")
                    .font(AppFont.heading(16))
                HStack(spacing: 8) {
                    Text("WATER LEVEL MONITOR · AUSTIN, TX")
                        .font(AppFont.body(10.5, weight: .semibold))
                        .tracking(0.4)
                        .foregroundStyle(theme.textMuted(0.45))
                    Text("·")
                        .foregroundStyle(theme.textMuted(0.25))
                    HStack(spacing: 5) {
                        Rectangle()
                            .fill(theme.accent)
                            .frame(width: 5, height: 5)
                        Text("LIVE · SYNCED 2 MIN AGO")
                            .font(AppFont.body(10.5, weight: .bold))
                            .foregroundStyle(theme.accent)
                    }
                }
            }

            Spacer()

            Button {
                showAnnualSummary.toggle()
            } label: {
                Text("ANNUAL SUMMARY")
                    .font(AppFont.body(11, weight: .semibold))
                    .tracking(0.3)
                    .foregroundStyle(showAnnualSummary ? theme.text : theme.textMuted(0.5))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showAnnualSummary, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("ANNUAL SUMMARY")
                        .font(AppFont.body(13, weight: .heavy))
                        .tracking(0.2)
                    HistoricalTableView(theme: theme)
                }
                .padding(24)
                .frame(minWidth: 520)
                .background(theme.background)
                .foregroundStyle(theme.text)
            }

            FlatSegmentedControl(
                options: [false, true],
                label: { $0 ? "DARK" : "LIGHT" },
                selection: $state.isDark,
                theme: theme,
                fontSize: 11
            )
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
