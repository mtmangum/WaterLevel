//
//  DashboardChartCard.swift
//  WaterLevel
//
//  Jan–Dec overlay chart showing 2022–2026 as individually toggleable year lines.
//  2026 uses live daily readings (monthly averages → Catmull-Rom bezier).
//  2022–2025 use static representative curves.
//

import SwiftUI

// MARK: - Data types

private struct YearSeries: Identifiable {
    var id: String { year }
    let year: String
    let color: Color
    let start: CGPoint
    let curves: [CubicSegment]
    let end: CGPoint
    let dotPosition: CGPoint?
}

// MARK: - Static chart data (2022–2025)

private let staticYearSeries: [YearSeries] = [
    YearSeries(
        year: "2025",
        color: Theme.neutral500,
        start: CGPoint(x: 40, y: 150),
        curves: [
            CubicSegment(c1: CGPoint(x: 100, y: 148), c2: CGPoint(x: 200, y: 130), end: CGPoint(x: 300, y: 108)),
            CubicSegment(c1: CGPoint(x: 400, y: 96),  c2: CGPoint(x: 500, y: 116), end: CGPoint(x: 600, y: 150)),
            CubicSegment(c1: CGPoint(x: 700, y: 182), c2: CGPoint(x: 800, y: 196), end: CGPoint(x: 900, y: 186)),
        ],
        end: CGPoint(x: 1000, y: 176),
        dotPosition: nil
    ),
    YearSeries(
        year: "2024",
        color: Theme.neutral600,
        start: CGPoint(x: 40, y: 142),
        curves: [
            CubicSegment(c1: CGPoint(x: 100, y: 136), c2: CGPoint(x: 200, y: 124), end: CGPoint(x: 300, y: 150)),
            CubicSegment(c1: CGPoint(x: 400, y: 178), c2: CGPoint(x: 500, y: 168), end: CGPoint(x: 600, y: 142)),
            CubicSegment(c1: CGPoint(x: 700, y: 120), c2: CGPoint(x: 800, y: 130), end: CGPoint(x: 900, y: 150)),
        ],
        end: CGPoint(x: 1000, y: 158),
        dotPosition: nil
    ),
    YearSeries(
        year: "2023",
        color: Theme.neutral700,
        start: CGPoint(x: 40, y: 168),
        curves: [
            CubicSegment(c1: CGPoint(x: 100, y: 172), c2: CGPoint(x: 200, y: 160), end: CGPoint(x: 300, y: 132)),
            CubicSegment(c1: CGPoint(x: 400, y: 112), c2: CGPoint(x: 500, y: 124), end: CGPoint(x: 600, y: 162)),
            CubicSegment(c1: CGPoint(x: 700, y: 194), c2: CGPoint(x: 800, y: 206), end: CGPoint(x: 900, y: 198)),
        ],
        end: CGPoint(x: 1000, y: 188),
        dotPosition: nil
    ),
    YearSeries(
        year: "2022",
        color: Theme.neutral800,
        start: CGPoint(x: 40, y: 138),
        curves: [
            CubicSegment(c1: CGPoint(x: 100, y: 132), c2: CGPoint(x: 200, y: 118), end: CGPoint(x: 300, y: 142)),
            CubicSegment(c1: CGPoint(x: 400, y: 162), c2: CGPoint(x: 500, y: 148), end: CGPoint(x: 600, y: 132)),
            CubicSegment(c1: CGPoint(x: 700, y: 122), c2: CGPoint(x: 800, y: 136), end: CGPoint(x: 900, y: 158)),
        ],
        end: CGPoint(x: 1000, y: 166),
        dotPosition: nil
    ),
]

// Placeholder shown while live data loads
private let placeholder2026 = YearSeries(
    year: "2026",
    color: Theme.water,
    start: CGPoint(x: 40, y: 146),
    curves: [
        CubicSegment(c1: CGPoint(x: 100, y: 150), c2: CGPoint(x: 200, y: 152), end: CGPoint(x: 300, y: 120)),
        CubicSegment(c1: CGPoint(x: 400, y: 84),  c2: CGPoint(x: 490, y: 105), end: CGPoint(x: 560, y: 118)),
    ],
    end: CGPoint(x: 560, y: 118),
    dotPosition: CGPoint(x: 560, y: 118)
)

private let chartAvgStart = CGPoint(x: 40, y: 120)
private let chartAvgCurves: [CubicSegment] = [
    CubicSegment(c1: CGPoint(x: 100, y: 116), c2: CGPoint(x: 200, y: 112), end: CGPoint(x: 300, y: 100)),
    CubicSegment(c1: CGPoint(x: 400, y: 90),  c2: CGPoint(x: 500, y: 96),  end: CGPoint(x: 600, y: 118)),
    CubicSegment(c1: CGPoint(x: 700, y: 140), c2: CGPoint(x: 800, y: 150), end: CGPoint(x: 900, y: 146)),
]
private let chartAvgEnd = CGPoint(x: 1000, y: 142)

private let monthXLabels: [(x: CGFloat, text: String)] = [
    (0, "JAN"), (160, "MAR"), (320, "MAY"), (480, "JUL"), (640, "SEP"), (800, "NOV"), (940, "DEC"),
]

// SVG y ↔ feet conversions (681 ft = y=34, 605 ft = y=226)
private func svgYToFt(_ svgY: CGFloat) -> CGFloat {
    min(max(681.0 - (svgY - 34.0) * (76.0 / 192.0), 605), 681)
}
private func ftToSvgY(_ ft: Double) -> CGFloat {
    34.0 + CGFloat(681.0 - ft) * (192.0 / 76.0)
}

// Month index (1–12) to SVG x at month center
private func monthToSvgX(_ month: Int) -> CGFloat {
    (CGFloat(month) - 0.5) * 80
}

private let kAvg = "30-YR AVG"

// MARK: - View

struct DashboardChartCard: View {
    let theme: Theme
    @EnvironmentObject var appState: AppState

    @State private var hiddenSeries: Set<String> = []
    @State private var hoverX: CGFloat? = nil

    // All year series: live 2026 (or placeholder) + static 2022–2025
    private var allSeries: [YearSeries] {
        [live2026] + staticYearSeries
    }

    private var allSeriesIDs: [String] {
        allSeries.map(\.year) + [kAvg]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("WATER LEVEL — 5-YEAR COMPARISON")
                    .font(AppFont.body(14.5, weight: .heavy))
                    .tracking(0.2)
                Spacer()
                legend
            }

            GeometryReader { geo in
                let size = geo.size
                ZStack {
                    gridlines(size: size)

                    if !hiddenSeries.contains(kAvg) {
                        svgPath(start: chartAvgStart, curves: chartAvgCurves, lineTo: chartAvgEnd, size: size)
                            .stroke(theme.chartAvgLine, style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                    }

                    ForEach(Array(allSeries.reversed()), id: \.year) { series in
                        if !hiddenSeries.contains(series.year) {
                            svgPath(start: series.start, curves: series.curves, lineTo: series.end, size: size)
                                .stroke(series.color, style: StrokeStyle(
                                    lineWidth: series.year == "2026" ? 2.5 : 1.5,
                                    lineCap: .round
                                ))

                            if let dot = series.dotPosition {
                                Circle()
                                    .fill(series.color)
                                    .frame(width: 9, height: 9)
                                    .position(scaledPoint(dot, size: size))
                            }
                        }
                    }

                    ForEach(Array(monthXLabels.enumerated()), id: \.offset) { _, label in
                        let pt = scaledPoint(CGPoint(x: label.x, y: 238), size: size)
                        Text(label.text)
                            .font(AppFont.body(11))
                            .foregroundStyle(theme.textMuted(0.55))
                            .position(x: pt.x + 12, y: pt.y)
                    }

                    if let hx = hoverX {
                        crosshair(hx: hx, size: size)
                    }
                }
                .contentShape(Rectangle())
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let loc): hoverX = loc.x
                    case .ended:          hoverX = nil
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 2))
    }

    // MARK: - Live 2026 series

    // Builds a YearSeries from real monthly-average readings.
    // Falls back to the static placeholder when data isn't loaded yet.
    private var live2026: YearSeries {
        let readings2026 = appState.readings.filter { $0.year == 2026 }
        guard readings2026.count >= 2 else { return placeholder2026 }

        // Monthly averages (only months that have data)
        var monthAvgs: [(month: Int, level: Double)] = []
        for month in 1...12 {
            let monthly = readings2026.filter { $0.month == month }
            guard !monthly.isEmpty else { continue }
            let avg = monthly.map(\.waterLevel).reduce(0, +) / Double(monthly.count)
            monthAvgs.append((month: month, level: avg))
        }
        guard monthAvgs.count >= 2 else { return placeholder2026 }

        // Convert to SVG points
        let pts = monthAvgs.map { ma in
            CGPoint(x: monthToSvgX(ma.month), y: ftToSvgY(ma.level))
        }

        // Catmull-Rom → cubic bezier for smooth interpolation
        var segments: [CubicSegment] = []
        for i in 0..<pts.count - 1 {
            let p0 = pts[max(0, i - 1)]
            let p1 = pts[i]
            let p2 = pts[i + 1]
            let p3 = pts[min(pts.count - 1, i + 2)]
            let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
            let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
            segments.append(CubicSegment(c1: c1, c2: c2, end: p2))
        }

        return YearSeries(
            year: "2026",
            color: Theme.water,
            start: pts[0],
            curves: segments,
            end: pts.last!,
            dotPosition: pts.last
        )
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 8) {
            ForEach(allSeries) { series in
                legendToggle(id: series.year, color: series.color, dashed: false, label: series.year)
            }
            legendToggle(id: kAvg, color: theme.chartAvgLine, dashed: true, label: "30-YR AVG")
        }
        .font(AppFont.body(11, weight: .semibold))
        .foregroundStyle(theme.textMuted(0.6))
    }

    private func legendToggle(id: String, color: Color, dashed: Bool, label: String) -> some View {
        let hidden = hiddenSeries.contains(id)
        return HStack(spacing: 5) {
            Path { p in
                p.move(to: CGPoint(x: 0, y: 1.25))
                p.addLine(to: CGPoint(x: 14, y: 1.25))
            }
            .stroke(hidden ? theme.divider : color,
                    style: StrokeStyle(lineWidth: 2.5, dash: dashed ? [3, 2] : []))
            .frame(width: 14, height: 2.5)
            Text(label).tracking(0.3)
        }
        .opacity(hidden ? 0.35 : 1)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            let ids = allSeriesIDs
            let isIsolated = !hiddenSeries.contains(id) && ids.filter { $0 != id }.allSatisfy { hiddenSeries.contains($0) }
            hiddenSeries = isIsolated ? [] : Set(ids.filter { $0 != id })
        }
        .onTapGesture(count: 1) {
            if hidden { hiddenSeries.remove(id) } else { hiddenSeries.insert(id) }
        }
    }

    // MARK: - Crosshair

    @ViewBuilder
    private func crosshair(hx: CGFloat, size: CGSize) -> some View {
        let svgX     = hx / size.width * 1000
        let flipLeft = hx > size.width * 0.62

        Path { p in
            p.move(to: CGPoint(x: hx, y: 0))
            p.addLine(to: CGPoint(x: hx, y: size.height * 0.86))
        }
        .stroke(Theme.water.opacity(0.45), lineWidth: 1)

        ForEach(Array(allSeries.reversed()), id: \.year) { series in
            yearDot(series: series, svgX: svgX, hx: hx, size: size)
        }

        crosshairTooltip(svgX: svgX, hx: hx, size: size, flipLeft: flipLeft)
    }

    @ViewBuilder
    private func yearDot(series: YearSeries, svgX: CGFloat, hx: CGFloat, size: CGSize) -> some View {
        if !hiddenSeries.contains(series.year), let svgY = levelY(for: series, atSvgX: svgX) {
            let screenY = svgY * size.height / 255
            Circle()
                .fill(series.color)
                .overlay(series.year == "2026" ? Circle().strokeBorder(theme.surface, lineWidth: 2) : nil)
                .frame(width: series.year == "2026" ? 9 : 7, height: series.year == "2026" ? 9 : 7)
                .position(x: hx, y: screenY)
        }
    }

    @ViewBuilder
    private func crosshairTooltip(svgX: CGFloat, hx: CGFloat, size: CGSize, flipLeft: Bool) -> some View {
        let visible = allSeries.filter { !hiddenSeries.contains($0.year) && levelY(for: $0, atSvgX: svgX) != nil }
        if !visible.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text(dateLabel(atSvgX: svgX))
                    .font(AppFont.body(10.5, weight: .bold))
                    .tracking(0.3)
                    .foregroundStyle(theme.textMuted(0.55))
                ForEach(visible, id: \.year) { series in
                    if let svgY = levelY(for: series, atSvgX: svgX) {
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(series.color)
                                .frame(width: 10, height: 2)
                            Text(series.year)
                                .font(AppFont.body(11, weight: .semibold))
                                .foregroundStyle(theme.textMuted(0.6))
                            Spacer()
                            Text(String(format: "%.1f ft", svgYToFt(svgY)))
                                .font(AppFont.body(12, weight: .heavy))
                                .foregroundStyle(theme.text)
                        }
                        .frame(minWidth: 128)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(theme.background)
            .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 1))
            .fixedSize()
            .position(
                x: flipLeft ? hx - 80 : hx + 80,
                y: 72
            )
        }
    }

    // MARK: - Bezier sampling

    private func evalBezier(_ curves: [CubicSegment], start: CGPoint, t: CGFloat) -> CGPoint {
        guard !curves.isEmpty else { return start }
        let segIdx = min(Int(t), curves.count - 1)
        let lT = t - CGFloat(segIdx)
        let p0 = segIdx == 0 ? start : curves[segIdx - 1].end
        let s  = curves[segIdx]
        let u  = 1 - lT
        return CGPoint(
            x: u*u*u*p0.x + 3*u*u*lT*s.c1.x + 3*u*lT*lT*s.c2.x + lT*lT*lT*s.end.x,
            y: u*u*u*p0.y + 3*u*u*lT*s.c1.y + 3*u*lT*lT*s.c2.y + lT*lT*lT*s.end.y
        )
    }

    private func levelY(for series: YearSeries, atSvgX targetX: CGFloat) -> CGFloat? {
        let curves   = series.curves
        let start    = series.start
        let lineEnd  = series.end
        let segCount = CGFloat(curves.count)
        var prev = start
        for i in 1...300 {
            let t  = CGFloat(i) / 300 * segCount
            let pt = evalBezier(curves, start: start, t: t)
            if prev.x <= targetX && pt.x >= targetX {
                let dx = pt.x - prev.x
                let frac = dx == 0 ? 0.5 : (targetX - prev.x) / dx
                return prev.y + frac * (pt.y - prev.y)
            }
            prev = pt
        }
        if let lastEnd = curves.last?.end, lastEnd.x <= targetX, lineEnd.x >= targetX {
            let dx = lineEnd.x - lastEnd.x
            guard dx != 0 else { return lastEnd.y }
            return lastEnd.y + (targetX - lastEnd.x) / dx * (lineEnd.y - lastEnd.y)
        }
        return nil
    }

    private func dateLabel(atSvgX x: CGFloat) -> String {
        let months = ["JAN","FEB","MAR","APR","MAY","JUN",
                      "JUL","AUG","SEP","OCT","NOV","DEC"]
        let idx = max(0, min(11, Int(x / 80)))
        return months[idx]
    }

    // MARK: - Gridlines

    private func gridlines(size: CGSize) -> some View {
        ZStack {
            gridline(y: 34,  label: "681", accent: true,  dashed: false, size: size)
            gridline(y: 98,  label: "655", accent: false, dashed: true,  size: size)
            gridline(y: 162, label: "630", accent: false, dashed: true,  size: size)
            gridline(y: 226, label: "605", accent: true,  dashed: false, size: size)
        }
    }

    private func gridline(y: CGFloat, label: String, accent: Bool, dashed: Bool, size: CGSize) -> some View {
        let start = scaledPoint(CGPoint(x: 40, y: y),   size: size)
        let end   = scaledPoint(CGPoint(x: 1000, y: y), size: size)
        return ZStack(alignment: .topLeading) {
            Path { p in
                p.move(to: start)
                p.addLine(to: end)
            }
            .stroke(accent ? theme.accent : theme.divider,
                    style: StrokeStyle(lineWidth: 1, dash: dashed ? [2, 4] : []))
            Text(label)
                .font(AppFont.body(10.5, weight: accent ? .bold : .regular))
                .foregroundStyle(accent ? theme.accent : theme.textMuted(0.45))
                .position(x: 14, y: start.y - 4)
        }
    }
}
