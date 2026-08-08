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
        return String(format: "%.1f%%", r.percentFull)
    }

    private static let cfsFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()

    private func formatCfs(_ value: Double) -> String {
        (Self.cfsFormatter.string(from: NSNumber(value: value)) ?? "\(Int(value))") + " cfs"
    }

    // Positive net cfs → inflow label; threshold below 10 cfs = Steady
    private var inflowString: String {
        guard let cfs = appState.dailyNetCfs else { return "—" }
        guard cfs > 10 else { return "Steady" }
        return formatCfs(cfs)
    }

    private var inflowDetail: String? { nil }

    // Negative net cfs → outflow label
    private var outflowString: String {
        guard let cfs = appState.dailyNetCfs else { return "—" }
        guard cfs < -10 else { return "Steady" }
        return formatCfs(abs(cfs))
    }

    private var outflowDetail: String? { nil }

    private var vsAvgString: String {
        guard let current = latest?.waterLevel,
              let avg = appState.thirtyYearAvgLevel else { return "—" }
        let diff = current - avg
        return String(format: "%+.1f ft", diff)
    }

    private var vsAvgDetail: String? { nil }

    private var vsAvgColor: Color? {
        guard let current = latest?.waterLevel,
              let avg = appState.thirtyYearAvgLevel else { return nil }
        return current >= avg ? Theme.water : theme.accent
    }

    var body: some View {
        HStack(spacing: 0) {
            statItem(label: "CURRENT LEVEL", value: levelString, valueColor: Theme.water)
            divider
            statItem(label: "INFLOW",        value: inflowString,  detail: inflowDetail)
            divider
            statItem(label: "OUTFLOW",       value: outflowString, detail: outflowDetail)
            divider
            statItem(label: "VS 30-YR AVG",  value: vsAvgString,   valueColor: vsAvgColor, detail: vsAvgDetail)
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
