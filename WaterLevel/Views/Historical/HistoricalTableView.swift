//
//  HistoricalTableView.swift
//  WaterLevel

import SwiftUI

private struct YearRow: Identifiable {
    let id = UUID()
    let year: String
    let min: String
    let max: String
    let avg: String
    let percentFull: String
}

struct HistoricalTableView: View {
    let theme: Theme
    @EnvironmentObject var appState: AppState

    private var rows: [YearRow] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = (currentYear - 4)...currentYear

        return years.reversed().compactMap { year in
            let readings = appState.historicalReadings.filter { $0.year == year }
            guard !readings.isEmpty else { return nil }

            let levels = readings.map(\.waterLevel)
            let minFt = levels.min()!
            let maxFt = levels.max()!
            let avgFt = levels.reduce(0, +) / Double(levels.count)

            // Year-end % full: use Dec 31 reading, or last available day for current year
            let yearEnd = readings.filter { year == currentYear ? true : $0.month == 12 }
                .sorted { $0.date > $1.date }.first
            let pctStr = yearEnd.map { String(format: "%.0f%%", $0.percentFull) } ?? "—"

            let label = year == currentYear ? "\(year) (YTD)" : "\(year)"
            return YearRow(
                year: label,
                min:  String(format: "%.1f", minFt),
                max:  String(format: "%.1f", maxFt),
                avg:  String(format: "%.1f", avgFt),
                percentFull: pctStr
            )
        }
    }

    private let columns = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
    ]

    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 0) {
                header("Year")
                header("Min (ft)")
                header("Max (ft)")
                header("Avg (ft)")
                header("Year-end % full")
            }
            .padding(.top, 12)
            .padding(.bottom, 10)
            .padding(.horizontal, 20)
            .overlay(alignment: .bottom) {
                Rectangle().fill(theme.divider).frame(height: 2)
            }

            if rows.isEmpty {
                Text("Loading…")
                    .font(AppFont.body(13))
                    .foregroundStyle(theme.textMuted(0.45))
                    .padding(24)
            } else {
                ForEach(rows) { row in
                    LazyVGrid(columns: columns, spacing: 0) {
                        cell(row.year)
                        cell(row.min)
                        cell(row.max)
                        cell(row.avg)
                        cell(row.percentFull)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .overlay(alignment: .bottom) {
                        if row.id != rows.last?.id {
                            Rectangle().fill(theme.divider.opacity(0.5)).frame(height: 1)
                        }
                    }
                }
            }
        }
        .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 2))
    }

    private func header(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AppFont.body(10.5, weight: .bold))
            .tracking(0.4)
            .foregroundStyle(theme.textMuted(0.5))
    }

    private func cell(_ text: String) -> some View {
        Text(text)
            .font(AppFont.body(13.5))
            .foregroundStyle(theme.text)
    }
}
