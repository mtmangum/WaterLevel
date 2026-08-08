//
//  HistoricalChartCard.swift
//  WaterLevel
//
//  Jan-Dec multi-year comparison: current year (accent, solid, endpoint dot),
//  two prior years (neutral, varying weight), and the 30-yr average (dashed).
//

import SwiftUI

private let avgCurve: [CubicSegment] = [
    CubicSegment(c1: CGPoint(x: 100, y: 116), c2: CGPoint(x: 200, y: 112), end: CGPoint(x: 300, y: 100)),
    CubicSegment(c1: CGPoint(x: 400, y: 90), c2: CGPoint(x: 500, y: 96), end: CGPoint(x: 600, y: 118)),
    CubicSegment(c1: CGPoint(x: 700, y: 140), c2: CGPoint(x: 800, y: 150), end: CGPoint(x: 900, y: 146)),
]

private let year2Curve: [CubicSegment] = [ // 2025, neutral-600
    CubicSegment(c1: CGPoint(x: 100, y: 148), c2: CGPoint(x: 200, y: 130), end: CGPoint(x: 300, y: 108)),
    CubicSegment(c1: CGPoint(x: 400, y: 96), c2: CGPoint(x: 500, y: 116), end: CGPoint(x: 600, y: 150)),
    CubicSegment(c1: CGPoint(x: 700, y: 182), c2: CGPoint(x: 800, y: 196), end: CGPoint(x: 900, y: 186)),
]

private let year1Curve: [CubicSegment] = [ // 2024, neutral-800
    CubicSegment(c1: CGPoint(x: 100, y: 136), c2: CGPoint(x: 200, y: 124), end: CGPoint(x: 300, y: 150)),
    CubicSegment(c1: CGPoint(x: 400, y: 178), c2: CGPoint(x: 500, y: 168), end: CGPoint(x: 600, y: 142)),
    CubicSegment(c1: CGPoint(x: 700, y: 120), c2: CGPoint(x: 800, y: 130), end: CGPoint(x: 900, y: 150)),
]

private let currentYearCurve: [CubicSegment] = [ // 2026, accent
    CubicSegment(c1: CGPoint(x: 100, y: 150), c2: CGPoint(x: 200, y: 152), end: CGPoint(x: 300, y: 120)),
    CubicSegment(c1: CGPoint(x: 400, y: 84), c2: CGPoint(x: 500, y: 110), end: CGPoint(x: 600, y: 168)),
    CubicSegment(c1: CGPoint(x: 700, y: 196), c2: CGPoint(x: 800, y: 206), end: CGPoint(x: 900, y: 190)),
]

private let monthLabels: [(x: CGFloat, text: String)] = [
    (0, "JAN"), (160, "MAR"), (320, "MAY"), (480, "JUL"), (640, "SEP"), (800, "NOV"), (940, "DEC"),
]

struct HistoricalChartCard: View {
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LEVEL BY YEAR — JAN THROUGH DEC")
                    .font(AppFont.body(14.5, weight: .heavy))
                    .tracking(0.2)
                Spacer()
                legend
            }

            GeometryReader { geo in
                let size = geo.size
                ZStack {
                    gridlines(size: size)

                    svgPath(start: CGPoint(x: 0, y: 120), curves: avgCurve, lineTo: CGPoint(x: 1000, y: 142), size: size)
                        .stroke(theme.chartAvgLine, style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                    svgPath(start: CGPoint(x: 0, y: 150), curves: year2Curve, lineTo: CGPoint(x: 1000, y: 176), size: size)
                        .stroke(Theme.neutral600, lineWidth: 2)
                    svgPath(start: CGPoint(x: 0, y: 142), curves: year1Curve, lineTo: CGPoint(x: 1000, y: 158), size: size)
                        .stroke(Theme.neutral800, lineWidth: 2)
                    svgPath(start: CGPoint(x: 0, y: 146), curves: currentYearCurve, size: size)
                        .stroke(theme.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                    let dot = scaledPoint(CGPoint(x: 900, y: 190), size: size)
                    Circle().fill(theme.accent).frame(width: 9, height: 9).position(dot)

                    ForEach(Array(monthLabels.enumerated()), id: \.offset) { _, label in
                        let pt = scaledPoint(CGPoint(x: label.x, y: 300), size: size)
                        Text(label.text)
                            .font(AppFont.body(11))
                            .foregroundStyle(theme.textMuted(0.55))
                            .position(x: pt.x + 12, y: pt.y)
                    }
                }
            }
            .frame(height: 280)
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 2))
    }

    private var legend: some View {
        HStack(spacing: 10) {
            Tag(text: "2026", style: .accent, theme: theme)
            Tag(text: "2025", style: .neutral, theme: theme)
            Tag(text: "2024", style: .neutral, theme: theme)
            Tag(text: "30-YR AVG", style: .outline, theme: theme)
        }
    }

    private func gridlines(size: CGSize) -> some View {
        ZStack {
            gridline(y: 34, label: "681", accent: true, dashed: false, size: size)
            gridline(y: 98, label: "655", accent: false, dashed: true, size: size)
            gridline(y: 162, label: "630", accent: false, dashed: true, size: size)
            gridline(y: 226, label: "605", accent: true, dashed: false, size: size)
        }
    }

    private func gridline(y: CGFloat, label: String, accent: Bool, dashed: Bool, size: CGSize) -> some View {
        let start = scaledPoint(CGPoint(x: 40, y: y), size: size)
        let end = scaledPoint(CGPoint(x: 1000, y: y), size: size)
        return ZStack(alignment: .topLeading) {
            Path { p in
                p.move(to: start)
                p.addLine(to: end)
            }
            .stroke(accent ? theme.accent : theme.divider, style: StrokeStyle(lineWidth: 1, dash: dashed ? [2, 4] : []))

            Text(label)
                .font(AppFont.body(10.5, weight: accent ? .bold : .regular))
                .foregroundStyle(accent ? theme.accent : theme.textMuted(0.45))
                .position(x: 14, y: start.y - 4)
        }
    }
}
