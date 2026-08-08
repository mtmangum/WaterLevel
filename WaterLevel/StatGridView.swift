//
//  StatGridView.swift
//  WaterLevel
//
//  Single-row 4-column stat grid: 280pt first column, three equal columns,
//  divided by 2px rules, no gaps.
//

import SwiftUI

struct StatGridView: View {
    let theme: Theme

    var body: some View {
        HStack(spacing: 0) {
            currentLevelCell
                .frame(width: 280, alignment: .leading)
            divider
            statCell(kicker: "INFLOW", value: "1,240 cfs", detail: "↑ 8% vs yesterday")
            divider
            statCell(kicker: "OUTFLOW", value: "640 cfs", detail: "Steady release")
            divider
            statCell(kicker: "VS HISTORICAL AVG", value: "−6.1 ft", valueColor: theme.accent, detail: "Below the 30-yr average")
        }
        .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 2))
    }

    private var divider: some View {
        Rectangle().fill(theme.divider).frame(width: 2)
    }

    private var currentLevelCell: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CURRENT LEVEL")
                .font(AppFont.body(10.5, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(theme.accent)

            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text("638.4")
                    .font(AppFont.heading(38))
                    .foregroundStyle(theme.text)
                Text("FT")
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(theme.textMuted(0.55))
            }

            HStack(spacing: 8) {
                Tag(text: "72% FULL POOL", style: .accent, theme: theme)
                Text("Updated 6:00 AM")
                    .font(AppFont.body(11))
                    .foregroundStyle(theme.textMuted(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statCell(kicker: String, value: String, valueColor: Color? = nil, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(kicker)
                .font(AppFont.body(10.5, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(theme.textMuted(0.55))
            Text(value)
                .font(AppFont.body(20, weight: .heavy))
                .foregroundStyle(valueColor ?? theme.text)
            Text(detail)
                .font(AppFont.body(12.5))
                .foregroundStyle(theme.textMuted(0.55))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
