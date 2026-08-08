//
//  SidebarView.swift
//  WaterLevel
//

import SwiftUI

private struct NavItem: Identifiable {
    let id = UUID()
    let title: String
    let tab: AppTab?
}

private let navItems: [NavItem] = [
    NavItem(title: "Dashboard", tab: .dashboard),
    NavItem(title: "Historical Trends", tab: .historical),
    NavItem(title: "Alerts", tab: nil),
    NavItem(title: "Settings", tab: nil),
]

struct SidebarView: View {
    @ObservedObject var state: AppState
    var theme: Theme { state.theme }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Space for the native traffic-light controls (fullSizeContentView titlebar).
            Spacer().frame(height: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text("TRAVIS LEVEL")
                    .font(AppFont.heading(16))
                    .foregroundStyle(theme.text)
                Text("WATER LEVEL MONITOR")
                    .font(AppFont.body(10.5, weight: .semibold))
                    .tracking(0.4)
                    .foregroundStyle(theme.textMuted(0.45))
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(navItems) { item in
                    NavRow(item: item, state: state)
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 14) {
                FlatSegmentedControl(
                    options: [false, true],
                    label: { $0 ? "DARK" : "LIGHT" },
                    selection: $state.isDark,
                    theme: theme,
                    fontSize: 11,
                    expand: true
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("LAKE TRAVIS, TX")
                        .font(AppFont.body(10.5, weight: .semibold))
                        .tracking(0.3)
                        .foregroundStyle(theme.textMuted(0.5))
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(theme.accent)
                            .frame(width: 6, height: 6)
                        Text("LIVE · SYNCED 2 MIN AGO")
                            .font(AppFont.body(11.5, weight: .bold))
                            .foregroundStyle(theme.accent)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            .overlay(alignment: .top) {
                Rectangle().fill(theme.divider).frame(height: 2)
            }
        }
        .frame(width: 224)
        .frame(maxHeight: .infinity)
        .background(theme.background)
        .overlay(alignment: .trailing) {
            Rectangle().fill(theme.divider).frame(width: 2)
        }
    }
}

private struct NavRow: View {
    let item: NavItem
    @ObservedObject var state: AppState
    var theme: Theme { state.theme }

    private var isActive: Bool { item.tab != nil && item.tab == state.tab }
    private var isEnabled: Bool { item.tab != nil }

    var body: some View {
        Button {
            if let tab = item.tab { state.tab = tab }
        } label: {
            Text(item.title)
                .font(AppFont.body(13, weight: .bold))
                .tracking(0.3)
                .textCase(.uppercase)
                .foregroundStyle(isActive ? theme.text : theme.textMuted(isEnabled ? 0.6 : 0.4))
                .padding(.horizontal, 20)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isActive ? theme.surface : Color.clear)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(isActive ? theme.accent : Color.clear)
                        .frame(width: 3)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
