//
//  StatGridView.swift
//  WaterLevel
//

import SwiftUI

struct StatGridView: View {
    let theme: Theme
    @EnvironmentObject var appState: AppState

    private var latest: DailyReading? { appState.latestReading }

    private var levelString: String {
        guard let r = latest else { return "—" }
        return String(format: "%.1f ft", r.waterLevel)
    }

    private var capacityString: String {
        guard let r = latest else { return "—" }
        return String(format: "%.0f%%", r.percentFull)
    }

    var body: some View {
        HStack(spacing: 0) {
            statItem(label: "CURRENT LEVEL", value: levelString, valueColor: Theme.water)
            divider
            statItem(label: "INFLOW",        value: "1,240 cfs", detail: "↑ 8%")
            divider
            statItem(label: "OUTFLOW",       value: "640 cfs",   detail: "Steady")
            divider
            statItem(label: "VS 30-YR AVG",  value: "−6.1 ft",  valueColor: theme.accent)
            divider
            statItem(label: "CAPACITY",      value: capacityString)
        }
        .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 2))
    }

    private var divider: some View {
        Rectangle()
            .fill(theme.divider)
            .frame(width: 1.5)
            .padding(.vertical, 4)
    }

    private func statItem(label: String, value: String, valueColor: Color? = nil, detail: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppFont.body(10.5, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(theme.textMuted(0.45))
            Text(value)
                .font(AppFont.heading(22))
                .foregroundStyle(valueColor ?? theme.text)
            if let detail {
                Text(detail)
                    .font(AppFont.body(12))
                    .foregroundStyle(theme.textMuted(0.45))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
