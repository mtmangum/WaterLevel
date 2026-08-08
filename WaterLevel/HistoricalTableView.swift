//
//  HistoricalTableView.swift
//  WaterLevel
//

import SwiftUI

private struct YearRow: Identifiable {
    let id = UUID()
    let year: String
    let min: String
    let max: String
    let avg: String
    let percentFull: String
}

private let rows: [YearRow] = [
    YearRow(year: "2026 (YTD)", min: "630.1", max: "648.9", avg: "639.5", percentFull: "72%"),
    YearRow(year: "2025", min: "612.8", max: "661.2", avg: "638.0", percentFull: "58%"),
    YearRow(year: "2024", min: "625.4", max: "670.9", avg: "649.8", percentFull: "81%"),
    YearRow(year: "2023", min: "608.0", max: "642.1", avg: "624.7", percentFull: "44%"),
    YearRow(year: "2022", min: "617.3", max: "655.6", avg: "636.2", percentFull: "63%"),
]

struct HistoricalTableView: View {
    let theme: Theme

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
