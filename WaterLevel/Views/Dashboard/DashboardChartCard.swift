//
//  DashboardChartCard.swift
//  WaterLevel
//
//  Jan–Dec overlay chart showing 2022–2026 as individually toggleable year lines.
//  All year lines use actual daily readings from historicalReadings / readings.
//  Drag horizontally to zoom into a time range; RESET to restore full view.
//  Y-axis scales dynamically to the data range of the currently visible series.
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

private let placeholder2026 = YearSeries(
    year: "2026",
    color: Theme.water,
    start: CGPoint(x: 80, y: 146),
    curves: [
        CubicSegment(c1: CGPoint(x: 140, y: 150), c2: CGPoint(x: 240, y: 152), end: CGPoint(x: 340, y: 120)),
        CubicSegment(c1: CGPoint(x: 440, y: 84),  c2: CGPoint(x: 530, y: 105), end: CGPoint(x: 600, y: 118)),
    ],
    end: CGPoint(x: 600, y: 118),
    dotPosition: CGPoint(x: 600, y: 118)
)

// Month label positions: left edge of each month zone in SVG x (data starts at x=40 = Jan 1)
private let allMonthLabels: [(x: CGFloat, label: String)] = [
    (40, "JAN"), (120, "FEB"), (200, "MAR"), (280, "APR"),
    (360, "MAY"), (440, "JUN"), (520, "JUL"), (600, "AUG"),
    (680, "SEP"), (760, "OCT"), (840, "NOV"), (920, "DEC"),
]


private let kAvg = "30-YR AVG"

// MARK: - View

struct DashboardChartCard: View {
    let theme: Theme
    @EnvironmentObject var appState: AppState

    @State private var hiddenSeries: Set<String> = []
    @State private var hoverX: CGFloat? = nil

    @State private var zoomRange: ClosedRange<CGFloat> = 0...1000
    @State private var selectionStart: CGFloat? = nil
    @State private var selectionEnd: CGFloat? = nil

    private var isZoomed: Bool { zoomRange.lowerBound > 1 || zoomRange.upperBound < 999 }
    private var allSeries: [YearSeries] { [live2026] + historicalYearSeries }
    private var allSeriesIDs: [String] { allSeries.map(\.year) + [kAvg] }

    // MARK: - Dynamic Y-axis range

    /// SVG y range (top...bottom) covering all visible series within zoomRange,
    /// with ±5 ft padding in lake-ft units and clamped to a sensible range.
    private var chartYRange: ClosedRange<CGFloat> {
        var minSvgY: CGFloat = 9999
        var maxSvgY: CGFloat = -9999
        var foundData = false
        let xLo = zoomRange.lowerBound
        let xHi = zoomRange.upperBound

        func extend(_ pt: CGPoint) {
            guard pt.x >= xLo && pt.x <= xHi else { return }
            if !foundData { minSvgY = pt.y; maxSvgY = pt.y; foundData = true }
            else { minSvgY = min(minSvgY, pt.y); maxSvgY = max(maxSvgY, pt.y) }
        }

        for series in allSeries where !hiddenSeries.contains(series.year) {
            extend(series.start)
            let n = CGFloat(series.curves.count)
            let samples = max(200, series.curves.count)
            for i in 1...samples { extend(evalBezier(series.curves, start: series.start, t: CGFloat(i) / CGFloat(samples) * n)) }
            extend(series.end)
        }
        if !hiddenSeries.contains(kAvg), let avg = avgSeries {
            extend(avg.start)
            let n = CGFloat(avg.curves.count)
            let samples = max(60, avg.curves.count)
            for i in 1...samples { extend(evalBezier(avg.curves, start: avg.start, t: CGFloat(i) / CGFloat(samples) * n)) }
            extend(avg.end)
        }
        guard foundData else { return 34...226 }

        // Compute ft range with ±5 ft padding.
        // Upper: 710 ft (lake can flood above "full pool" 681 ft).
        // Lower: 560 ft (well below any historical drought record).
        let highFt = min(710.0, svgYToFt(minSvgY) + 5.0)
        let lowFt  = max(560.0, svgYToFt(maxSvgY) - 5.0)
        let midFt  = (highFt + lowFt) / 2.0
        // Enforce minimum 8 ft span so tightly-bunched data doesn't over-zoom
        let halfSpan = max(4.0, (highFt - lowFt) / 2.0)

        let topSvgY = ftToSvgY(min(710.0, midFt + halfSpan))
        let botSvgY = ftToSvgY(max(560.0, midFt - halfSpan))
        return topSvgY...botSvgY
    }

    /// Gridlines at nice ft intervals within chartYRange.
    /// Always includes the 681 ft (full pool) and 605 ft (low threshold) anchors when in range.
    private func dynamicGridlines() -> [(ft: Double, svgY: CGFloat, isAccent: Bool)] {
        let yr     = chartYRange
        let topFt  = svgYToFt(yr.lowerBound)
        let botFt  = svgYToFt(yr.upperBound)
        let span   = topFt - botFt

        let step: Double
        switch span {
        case ..<3:   step = 0.5
        case ..<6:   step = 1
        case ..<12:  step = 2
        case ..<25:  step = 5
        case ..<150: step = 10
        default:     step = 20
        }

        var ftSet = Set<Double>()
        var ft = ceil(botFt / step) * step
        while ft <= topFt + step * 0.01 { ftSet.insert(ft); ft += step }

        // Always include full-pool and low-threshold anchors if in range; suppress nearby computed lines
        for anchor in [681.0, 605.0] where anchor >= botFt - 0.5 && anchor <= topFt + 0.5 {
            ftSet = ftSet.filter { abs($0 - anchor) >= 3.0 }
            ftSet.insert(anchor)
        }

        return ftSet.sorted(by: >).compactMap { ft in
            let sy = ftToSvgY(ft)
            guard sy >= yr.lowerBound - 1 && sy <= yr.upperBound + 1 else { return nil }
            return (ft: ft, svgY: sy, isAccent: abs(ft - 681) < 0.01 || abs(ft - 605) < 0.01)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                Text("WATER LEVEL")
                    .font(AppFont.body(14.5, weight: .heavy))
                    .tracking(0.2)

                if isZoomed {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { zoomRange = 0...1000 }
                    } label: {
                        Text("RESET")
                            .font(AppFont.body(10, weight: .bold))
                            .tracking(0.4)
                            .foregroundStyle(Theme.water)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .overlay(Rectangle().strokeBorder(Theme.water.opacity(0.5), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
                legend
            }

            GeometryReader { geo in
                let size = geo.size
                let yr   = chartYRange
                let xSpan = zoomRange.upperBound - zoomRange.lowerBound

                ZStack {
                    gridlines(size: size, yr: yr)

                    if !hiddenSeries.contains(kAvg), let avg = avgSeries {
                        svgPath(start: avg.start, curves: avg.curves, lineTo: avg.end,
                                size: size, xRange: zoomRange, yRange: yr)
                            .stroke(theme.chartAvgLine, style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                    }

                    ForEach(Array(allSeries.reversed()), id: \.year) { series in
                        if !hiddenSeries.contains(series.year) {
                            svgPath(start: series.start, curves: series.curves, lineTo: series.end,
                                    size: size, xRange: zoomRange, yRange: yr)
                                .stroke(series.color, style: StrokeStyle(
                                    lineWidth: series.year == "2026" ? 2.5 : 1.5,
                                    lineCap: .round
                                ))

                            if let dot = series.dotPosition {
                                let dotPt = scaledPoint(dot, size: size, xRange: zoomRange, yRange: yr)
                                if dotPt.x >= 0 && dotPt.x <= size.width {
                                    Circle()
                                        .fill(series.color)
                                        .frame(width: 9, height: 9)
                                        .position(dotPt)
                                }
                            }
                        }
                    }

                    // Month labels pinned to the screen bottom regardless of y zoom
                    ForEach(Array(allMonthLabels.enumerated()), id: \.offset) { _, lbl in
                        if lbl.x < zoomRange.upperBound && (lbl.x + 80) > zoomRange.lowerBound {
                            let screenX = (lbl.x - zoomRange.lowerBound) / xSpan * size.width
                            Text(lbl.label)
                                .font(AppFont.body(11))
                                .foregroundStyle(theme.textMuted(0.55))
                                .position(x: screenX, y: size.height - 14)
                        }
                    }

                    // Selection highlight during drag
                    if let s = selectionStart, let e = selectionEnd {
                        let lo = min(s, e); let hi = max(s, e)
                        Rectangle()
                            .fill(Theme.water.opacity(0.1))
                            .frame(width: hi - lo, height: size.height)
                            .position(x: (lo + hi) / 2, y: size.height / 2)
                        Path { p in p.move(to: CGPoint(x: lo, y: 0)); p.addLine(to: CGPoint(x: lo, y: size.height)) }
                            .stroke(Theme.water.opacity(0.7), lineWidth: 1)
                        Path { p in p.move(to: CGPoint(x: hi, y: 0)); p.addLine(to: CGPoint(x: hi, y: size.height)) }
                            .stroke(Theme.water.opacity(0.7), lineWidth: 1)
                    }

                    if let hx = hoverX, selectionStart == nil {
                        crosshair(hx: hx, size: size, yr: yr)
                    }
                }
                .clipped()
                .contentShape(Rectangle())
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let loc): hoverX = loc.x
                    case .ended:          hoverX = nil
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 5, coordinateSpace: .local)
                        .onChanged { v in
                            if selectionStart == nil { selectionStart = v.startLocation.x }
                            selectionEnd = v.location.x
                        }
                        .onEnded { v in
                            defer { selectionStart = nil; selectionEnd = nil }
                            guard let start = selectionStart else { return }
                            let lo = min(start, v.location.x); let hi = max(start, v.location.x)
                            guard hi - lo > 15 else { return }
                            let span = zoomRange.upperBound - zoomRange.lowerBound
                            let newLo = zoomRange.lowerBound + (lo / size.width) * span
                            let newHi = zoomRange.lowerBound + (hi / size.width) * span
                            withAnimation(.easeInOut(duration: 0.18)) {
                                zoomRange = max(0, newLo)...min(1000, newHi)
                            }
                        }
                )
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    // MARK: - Live series

    private var live2026: YearSeries {
        let r = appState.readings.filter { $0.year == 2026 }
        return seriesFromDailyReadings(r, year: "2026", color: Theme.water, dotAtEnd: true)
            ?? placeholder2026
    }

    private var historicalYearSeries: [YearSeries] {
        let config: [(year: Int, color: Color)] = [
            (2025, Theme.neutral500),
            (2024, Theme.neutral600),
            (2023, Theme.neutral700),
            (2022, Theme.neutral800),
        ]
        return config.compactMap { (year, color) in
            guard let r = appState.chartYearDailyReadings[year], r.count >= 2 else { return nil }
            return seriesFromDailyReadings(r, year: "\(year)", color: color)
        }
    }

    private var avgSeries: YearSeries? {
        seriesFromMonthlyAvgs(appState.thirtyYearMonthlyAvgs, color: theme.chartAvgLine)
    }

    // MARK: - Series builders (Catmull-Rom → cubic bezier)

    private func readingToSvgX(month: Int, day: Int) -> CGFloat {
        let dims: [CGFloat] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        let dm = dims[max(0, min(11, month - 1))]
        // 40 left offset so Jan 1 aligns with the gridline left edge
        return 40.0 + CGFloat(month - 1) * 80.0 + CGFloat(day - 1) / dm * 80.0
    }

    private func buildSegments(pts: [CGPoint]) -> [CubicSegment] {
        guard pts.count >= 2 else { return [] }
        var segs: [CubicSegment] = []
        for i in 0..<pts.count - 1 {
            let p0 = pts[max(0, i - 1)], p1 = pts[i], p2 = pts[i + 1], p3 = pts[min(pts.count - 1, i + 2)]
            let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
            let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
            segs.append(CubicSegment(c1: c1, c2: c2, end: p2))
        }
        return segs
    }

    private func seriesFromDailyReadings(
        _ readings: [DailyReading],
        year: String,
        color: Color,
        dotAtEnd: Bool = false
    ) -> YearSeries? {
        guard readings.count >= 2 else { return nil }
        let pts = readings.map { r in
            CGPoint(x: readingToSvgX(month: r.month, day: r.day), y: ftToSvgY(r.waterLevel))
        }
        let segs = buildSegments(pts: pts)
        return YearSeries(year: year, color: color,
                          start: pts[0], curves: segs,
                          end: pts.last!, dotPosition: dotAtEnd ? pts.last : nil)
    }

    private func seriesFromMonthlyAvgs(
        _ avgs: [(month: Int, level: Double)],
        color: Color
    ) -> YearSeries? {
        guard avgs.count >= 2 else { return nil }
        var pts = avgs.map { CGPoint(x: monthToSvgX($0.month), y: ftToSvgY($0.level)) }
        // Extend to Dec 31 (x=1000) so the avg line spans the same range as the year lines
        let decLevel = avgs.first(where: { $0.month == 12 })?.level ?? avgs.last!.level
        pts.append(CGPoint(x: 1000, y: ftToSvgY(decLevel)))
        let segs = buildSegments(pts: pts)
        return YearSeries(year: kAvg, color: color,
                          start: pts[0], curves: segs,
                          end: pts.last!, dotPosition: nil)
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
            Path { p in p.move(to: CGPoint(x: 0, y: 1.25)); p.addLine(to: CGPoint(x: 14, y: 1.25)) }
                .stroke(hidden ? theme.divider : color,
                        style: StrokeStyle(lineWidth: 2.5, dash: dashed ? [3, 2] : []))
                .frame(width: 14, height: 2.5)
            Text(label).tracking(0.3)
        }
        .opacity(hidden ? 0.35 : 1)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            let ids = allSeriesIDs
            let isIsolated = !hiddenSeries.contains(id) &&
                ids.filter { $0 != id }.allSatisfy { hiddenSeries.contains($0) }
            hiddenSeries = isIsolated ? [] : Set(ids.filter { $0 != id })
        }
        .onTapGesture(count: 1) {
            if hidden { hiddenSeries.remove(id) } else { hiddenSeries.insert(id) }
        }
    }

    // MARK: - Crosshair

    @ViewBuilder
    private func crosshair(hx: CGFloat, size: CGSize, yr: ClosedRange<CGFloat>) -> some View {
        let span     = zoomRange.upperBound - zoomRange.lowerBound
        let svgX     = hx / size.width * span + zoomRange.lowerBound
        let flipLeft = hx > size.width * 0.62

        Path { p in
            p.move(to: CGPoint(x: hx, y: 0))
            p.addLine(to: CGPoint(x: hx, y: size.height - 28))
        }
        .stroke(Theme.water.opacity(0.45), lineWidth: 1)

        ForEach(Array(allSeries.reversed()), id: \.year) { series in
            yearDot(series: series, svgX: svgX, hx: hx, size: size, yr: yr)
        }

        crosshairTooltip(svgX: svgX, hx: hx, size: size, flipLeft: flipLeft)
    }

    @ViewBuilder
    private func yearDot(series: YearSeries, svgX: CGFloat, hx: CGFloat,
                         size: CGSize, yr: ClosedRange<CGFloat>) -> some View {
        if !hiddenSeries.contains(series.year), let svgY = levelY(for: series, atSvgX: svgX) {
            let ySpan   = yr.upperBound - yr.lowerBound
            let screenY = (svgY - yr.lowerBound) / ySpan * size.height
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
                            Rectangle().fill(series.color).frame(width: 10, height: 2)
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
            .position(x: flipLeft ? hx - 80 : hx + 80, y: 72)
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
        let segCount = CGFloat(series.curves.count)
        let sampleCount = max(600, series.curves.count * 2)
        var prev = series.start
        for i in 1...sampleCount {
            let pt = evalBezier(series.curves, start: series.start, t: CGFloat(i) / CGFloat(sampleCount) * segCount)
            if prev.x <= targetX && pt.x >= targetX {
                let dx = pt.x - prev.x
                return prev.y + (dx == 0 ? 0 : (targetX - prev.x) / dx) * (pt.y - prev.y)
            }
            prev = pt
        }
        if let lastEnd = series.curves.last?.end, lastEnd.x <= targetX, series.end.x >= targetX {
            let dx = series.end.x - lastEnd.x
            guard dx != 0 else { return lastEnd.y }
            return lastEnd.y + (targetX - lastEnd.x) / dx * (series.end.y - lastEnd.y)
        }
        return nil
    }

    private func dateLabel(atSvgX x: CGFloat) -> String {
        let months      = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]
        let daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        let adjusted    = max(0, x - 40.0)
        let idx         = max(0, min(11, Int(adjusted / 80)))
        let dm          = daysInMonth[idx]
        let pos         = (adjusted - CGFloat(idx * 80)) / 80.0
        let day         = max(1, min(dm, Int(pos * CGFloat(dm)) + 1))
        return "\(months[idx]) \(day)"
    }

    // MARK: - Gridlines

    private func gridlines(size: CGSize, yr: ClosedRange<CGFloat>) -> some View {
        let lines  = dynamicGridlines()
        let ySpan  = yr.upperBound - yr.lowerBound
        let leftX  = max(40, zoomRange.lowerBound)
        let xSpan  = zoomRange.upperBound - zoomRange.lowerBound
        let startX = (leftX - zoomRange.lowerBound) / xSpan * size.width

        return ZStack {
            ForEach(lines, id: \.ft) { gl in
                let screenY = (gl.svgY - yr.lowerBound) / ySpan * size.height
                ZStack(alignment: .topLeading) {
                    Path { p in
                        p.move(to: CGPoint(x: startX, y: screenY))
                        p.addLine(to: CGPoint(x: size.width, y: screenY))
                    }
                    .stroke(gl.isAccent ? theme.accent : theme.divider,
                            style: StrokeStyle(lineWidth: 1, dash: gl.isAccent ? [] : [3, 5]))

                    let label = gl.ft == Double(Int(gl.ft)) ? "\(Int(gl.ft))" : String(format: "%.1f", gl.ft)
                    Text(label)
                        .font(AppFont.body(10.5, weight: gl.isAccent ? .bold : .regular))
                        .foregroundStyle(gl.isAccent ? theme.accent : theme.textMuted(0.35))
                        .position(x: 14, y: max(8, screenY - 4))
                }
            }
        }
    }
}
