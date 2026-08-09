//
//  StatGridView.swift
//  WaterLevel
//

import SwiftUI

struct StatGridView: View {
    let theme: Theme
    @EnvironmentObject var appState: AppState

    private var latest: DailyReading? { appState.latestReading }

    // MARK: - Values

    private var levelString: String {
        guard let r = latest else { return "—" }
        return String(format: "%.1f ft", r.waterLevel)
    }

    private static let cfsFormatter: NumberFormatter = {
        let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 0; return f
    }()

    private func formatCfs(_ value: Double) -> String {
        (Self.cfsFormatter.string(from: NSNumber(value: value)) ?? "\(Int(value))") + " cfs"
    }

    private var inflowString: String {
        guard let cfs = appState.dailyNetCfs else { return "—" }
        guard cfs > 10 else { return "Steady" }
        return formatCfs(cfs)
    }

    private var outflowString: String {
        guard let cfs = appState.dailyNetCfs else { return "—" }
        guard cfs < -10 else { return "Steady" }
        return formatCfs(abs(cfs))
    }

    private var vsAvgString: String {
        guard let current = latest?.waterLevel,
              let avg = appState.thirtyYearAvgLevel else { return "—" }
        return String(format: "%+.1f ft", current - avg)
    }

    private var vsAvgColor: Color? {
        guard let current = latest?.waterLevel,
              let avg = appState.thirtyYearAvgLevel else { return nil }
        return current >= avg ? Theme.water : theme.accent
    }

    // MARK: - Detail helpers

    /// nil = no data, true = rising, false = falling
    private var trendDirection: Bool? {
        let r = appState.readings
        guard r.count >= 2 else { return nil }
        let diff = r[r.count - 1].waterLevel - r[r.count - 2].waterLevel
        guard abs(diff) >= 0.01 else { return nil }
        return diff > 0
    }

    /// % change in net inflow vs previous day — only valid when both days are net inflow
    private var inflowPctVsYday: Double? {
        let r = appState.readings
        guard r.count >= 3 else { return nil }
        let today = (r[r.count - 1].storage - r[r.count - 2].storage) * 0.504
        let yday  = (r[r.count - 2].storage - r[r.count - 3].storage) * 0.504
        guard today > 10 && yday > 10 else { return nil }
        return (today - yday) / yday * 100
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            statItem(label: "CURRENT LEVEL") {
                Text(levelString)
                    .font(AppFont.heading(22))
                    .foregroundStyle(Theme.water)
            } detail: {
                if let r = latest {
                    HStack(spacing: 5) {
                        Text(String(format: "%.1f%% full", r.percentFull))
                            .foregroundStyle(theme.textMuted(0.55))
                        if let rising = trendDirection {
                            Image(systemName: rising ? "arrow.up" : "arrow.down")
                                .foregroundStyle(rising ? Theme.water : theme.accent)
                            Text(rising ? "Rising" : "Falling")
                                .foregroundStyle(rising ? Theme.water : theme.accent)
                        }
                    }
                } else {
                    detailPlaceholder
                }
            }
            statItem(label: "INFLOW") {
                Text(inflowString)
                    .font(AppFont.heading(22))
                    .foregroundStyle(theme.text)
            } detail: {
                if let pct = inflowPctVsYday {
                    let sign = pct >= 0 ? "+" : ""
                    Text(String(format: "%@%.0f%% vs yesterday", sign, pct))
                        .foregroundStyle(pct >= 0 ? Theme.water : theme.accent)
                } else if let cfs = appState.dailyNetCfs, cfs < -10 {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                        Text("\(formatCfs(abs(cfs))) outbound")
                    }
                    .foregroundStyle(theme.accent)
                } else {
                    detailPlaceholder
                }
            }
            statItem(label: "OUTFLOW") {
                Text(outflowString)
                    .font(AppFont.heading(22))
                    .foregroundStyle(theme.text)
            } detail: {
                Text("NET DAILY")
                    .foregroundStyle(theme.textMuted(0.45))
            }
            statItem(label: "30-YR HISTORICAL AVG") {
                Text(vsAvgString)
                    .font(AppFont.heading(22))
                    .foregroundStyle(vsAvgColor ?? theme.text)
            } detail: {
                if let avg = appState.thirtyYearAvgLevel {
                    Text(String(format: "Hist. avg: %.1f ft", avg))
                        .foregroundStyle(theme.textMuted(0.55))
                } else {
                    detailPlaceholder
                }
            }
        }
    }

    // MARK: - Helpers

    /// Invisible text that reserves the same height as a real detail line.
    private var detailPlaceholder: some View {
        Text(" ").opacity(0)
    }

    private var divider: some View {
        Rectangle()
            .fill(theme.divider)
            .frame(width: 1)
            .padding(.vertical, 2)
    }

    private func statItem<V: View, D: View>(
        label: String,
        @ViewBuilder value: () -> V,
        @ViewBuilder detail: () -> D
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppFont.body(10.5, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(theme.textMuted(0.45))
            value()
            detail()
                .font(AppFont.body(11))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
