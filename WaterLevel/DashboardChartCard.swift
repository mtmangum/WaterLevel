//
//  DashboardChartCard.swift
//  WaterLevel
//
//  12-month trailing water level chart with mouse-hover crosshair and tooltip.
//

import SwiftUI

// MARK: - Per-range chart configs

private struct ChartConfig {
    let title: String
    let xLabels: [(x: CGFloat, text: String)]
    let levelStart: CGPoint
    let levelCurves: [CubicSegment]
    let levelEnd: CGPoint
    let avgStart: CGPoint
    let avgCurves: [CubicSegment]
    let avgEnd: CGPoint
    let dotPosition: CGPoint
}

private let config1M = ChartConfig(
    title: "WATER LEVEL — TRAILING 30 DAYS",
    xLabels: [(0, "JUL 10"), (330, "JUL 20"), (660, "JUL 30"), (920, "AUG 7")],
    levelStart: CGPoint(x: 0, y: 148),
    levelCurves: [
        CubicSegment(c1: CGPoint(x: 200, y: 140), c2: CGPoint(x: 400, y: 136), end: CGPoint(x: 600, y: 128)),
        CubicSegment(c1: CGPoint(x: 700, y: 122), c2: CGPoint(x: 850, y: 120), end: CGPoint(x: 1000, y: 118)),
    ],
    levelEnd: CGPoint(x: 1000, y: 118),
    avgStart: CGPoint(x: 0, y: 110),
    avgCurves: [
        CubicSegment(c1: CGPoint(x: 200, y: 108), c2: CGPoint(x: 400, y: 106), end: CGPoint(x: 600, y: 104)),
        CubicSegment(c1: CGPoint(x: 700, y: 103), c2: CGPoint(x: 850, y: 102), end: CGPoint(x: 1000, y: 100)),
    ],
    avgEnd: CGPoint(x: 1000, y: 100),
    dotPosition: CGPoint(x: 1000, y: 118)
)

private let config1Y = ChartConfig(
    title: "WATER LEVEL — TRAILING 12 MONTHS",
    xLabels: [(0, "AUG"), (160, "OCT"), (320, "DEC"), (480, "FEB"), (640, "APR"), (800, "JUN"), (960, "AUG")],
    levelStart: CGPoint(x: 0, y: 146),
    levelCurves: [
        CubicSegment(c1: CGPoint(x: 80, y: 150),  c2: CGPoint(x: 160, y: 152), end: CGPoint(x: 220, y: 120)),
        CubicSegment(c1: CGPoint(x: 300, y: 84),  c2: CGPoint(x: 380, y: 110), end: CGPoint(x: 460, y: 168)),
        CubicSegment(c1: CGPoint(x: 540, y: 196), c2: CGPoint(x: 620, y: 206), end: CGPoint(x: 700, y: 148)),
        CubicSegment(c1: CGPoint(x: 780, y: 102), c2: CGPoint(x: 860, y: 100), end: CGPoint(x: 940, y: 112)),
    ],
    levelEnd: CGPoint(x: 1000, y: 118),
    avgStart: CGPoint(x: 0, y: 110),
    avgCurves: [
        CubicSegment(c1: CGPoint(x: 80, y: 108),  c2: CGPoint(x: 160, y: 118), end: CGPoint(x: 220, y: 96)),
        CubicSegment(c1: CGPoint(x: 300, y: 68),  c2: CGPoint(x: 380, y: 86),  end: CGPoint(x: 460, y: 132)),
        CubicSegment(c1: CGPoint(x: 540, y: 150), c2: CGPoint(x: 620, y: 158), end: CGPoint(x: 700, y: 90)),
        CubicSegment(c1: CGPoint(x: 780, y: 58),  c2: CGPoint(x: 860, y: 68),  end: CGPoint(x: 940, y: 80)),
    ],
    avgEnd: CGPoint(x: 1000, y: 84),
    dotPosition: CGPoint(x: 1000, y: 118)
)

private let config5Y = ChartConfig(
    title: "WATER LEVEL — TRAILING 5 YEARS",
    xLabels: [(0, "2022"), (240, "2023"), (480, "2024"), (720, "2025"), (920, "2026")],
    levelStart: CGPoint(x: 0, y: 172),
    levelCurves: [
        CubicSegment(c1: CGPoint(x: 100, y: 220), c2: CGPoint(x: 200, y: 240), end: CGPoint(x: 300, y: 80)),
        CubicSegment(c1: CGPoint(x: 380, y: 60),  c2: CGPoint(x: 460, y: 100), end: CGPoint(x: 560, y: 70)),
        CubicSegment(c1: CGPoint(x: 650, y: 55),  c2: CGPoint(x: 740, y: 90),  end: CGPoint(x: 840, y: 180)),
        CubicSegment(c1: CGPoint(x: 900, y: 200), c2: CGPoint(x: 950, y: 160), end: CGPoint(x: 1000, y: 118)),
    ],
    levelEnd: CGPoint(x: 1000, y: 118),
    avgStart: CGPoint(x: 0, y: 110),
    avgCurves: [
        CubicSegment(c1: CGPoint(x: 250, y: 105), c2: CGPoint(x: 500, y: 112), end: CGPoint(x: 750, y: 108)),
        CubicSegment(c1: CGPoint(x: 875, y: 106), c2: CGPoint(x: 940, y: 104), end: CGPoint(x: 1000, y: 100)),
    ],
    avgEnd: CGPoint(x: 1000, y: 100),
    dotPosition: CGPoint(x: 1000, y: 118)
)

private let configAll = ChartConfig(
    title: "WATER LEVEL — ALL AVAILABLE DATA",
    xLabels: [(0, "2018"), (160, "2019"), (320, "2020"), (480, "2021"), (640, "2022"), (800, "2023"), (920, "2024")],
    levelStart: CGPoint(x: 0, y: 90),
    levelCurves: [
        CubicSegment(c1: CGPoint(x: 80, y: 60),   c2: CGPoint(x: 160, y: 50),  end: CGPoint(x: 240, y: 100)),
        CubicSegment(c1: CGPoint(x: 320, y: 150), c2: CGPoint(x: 400, y: 220), end: CGPoint(x: 480, y: 200)),
        CubicSegment(c1: CGPoint(x: 560, y: 180), c2: CGPoint(x: 630, y: 230), end: CGPoint(x: 700, y: 80)),
        CubicSegment(c1: CGPoint(x: 770, y: 55),  c2: CGPoint(x: 850, y: 70),  end: CGPoint(x: 920, y: 140)),
        CubicSegment(c1: CGPoint(x: 960, y: 130), c2: CGPoint(x: 980, y: 124), end: CGPoint(x: 1000, y: 118)),
    ],
    levelEnd: CGPoint(x: 1000, y: 118),
    avgStart: CGPoint(x: 0, y: 110),
    avgCurves: [
        CubicSegment(c1: CGPoint(x: 250, y: 108), c2: CGPoint(x: 500, y: 106), end: CGPoint(x: 750, y: 104)),
        CubicSegment(c1: CGPoint(x: 875, y: 102), c2: CGPoint(x: 940, y: 101), end: CGPoint(x: 1000, y: 100)),
    ],
    avgEnd: CGPoint(x: 1000, y: 100),
    dotPosition: CGPoint(x: 1000, y: 118)
)

private let rainfallBars: [(x: CGFloat, y: CGFloat, h: CGFloat)] = [
    (20, 230, 18), (80, 220, 28), (140, 238, 10), (220, 196, 52), (300, 180, 68),
    (380, 228, 20), (460, 234, 14), (540, 242, 6), (620, 236, 12), (700, 188, 60),
    (780, 222, 26), (860, 232, 16), (940, 240, 8),
]

// Y-axis scale: svgY=34 → 681 ft, svgY=260 → 605 ft (76 ft over 226 svg units)
private let svgYMin: CGFloat = 34
private let svgYRange: CGFloat = 226
private let ftTop: CGFloat = 681
private let ftRange: CGFloat = 76

private func svgYToFt(_ svgY: CGFloat) -> CGFloat {
    let raw = ftTop - (svgY - svgYMin) * (ftRange / svgYRange)
    return min(max(raw, 605), 681)
}

// MARK: - View

struct DashboardChartCard: View {
    let theme: Theme
    let range: RangeOption

    @State private var hoverX: CGFloat? = nil

    private var config: ChartConfig {
        switch range {
        case .oneMonth: config1M
        case .oneYear:  config1Y
        case .fiveYear: config5Y
        case .all:      configAll
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(config.title)
                    .font(AppFont.body(14.5, weight: .heavy))
                    .tracking(0.2)
                Spacer()
                legend
            }

            GeometryReader { geo in
                let size = geo.size
                ZStack {
                    gridlines(size: size)
                    rainfall(size: size)
                    svgPath(start: config.avgStart, curves: config.avgCurves, lineTo: config.avgEnd, size: size)
                        .stroke(theme.chartAvgLine, style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                    svgPath(start: config.levelStart, curves: config.levelCurves, lineTo: config.levelEnd, size: size)
                        .stroke(theme.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    let dot = scaledPoint(config.dotPosition, size: size)
                    Circle().fill(theme.accent).frame(width: 9, height: 9).position(dot)

                    ForEach(Array(config.xLabels.enumerated()), id: \.offset) { _, label in
                        let pt = scaledPoint(CGPoint(x: label.x, y: 300), size: size)
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
            .frame(height: 280)
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 2))
    }

    // MARK: - Crosshair overlay

    @ViewBuilder
    private func crosshair(hx: CGFloat, size: CGSize) -> some View {
        let svgX    = hx / size.width * 1000
        let svgY    = levelY(atSvgX: svgX) ?? 146
        let screenY = svgY * size.height / 320
        let ft      = svgYToFt(svgY)
        let flipLeft = hx > size.width * 0.62

        // Vertical tracking line (stops above x-axis labels)
        Path { p in
            p.move(to: CGPoint(x: hx, y: 0))
            p.addLine(to: CGPoint(x: hx, y: size.height * 0.86))
        }
        .stroke(theme.accent.opacity(0.45), lineWidth: 1)

        // Dot on the level curve
        Circle()
            .fill(theme.accent)
            .overlay(Circle().strokeBorder(theme.surface, lineWidth: 2))
            .frame(width: 9, height: 9)
            .position(x: hx, y: screenY)

        // Tooltip balloon
        VStack(alignment: .leading, spacing: 3) {
            Text(dateLabel(atSvgX: svgX))
                .font(AppFont.body(10.5, weight: .bold))
                .tracking(0.3)
                .foregroundStyle(theme.textMuted(0.55))
            Text(String(format: "%.1f ft", ft))
                .font(AppFont.body(15, weight: .heavy))
                .foregroundStyle(theme.accent)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(theme.surface)
        .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 1))
        .fixedSize()
        .position(
            x: flipLeft ? hx - 56 : hx + 56,
            y: max(36, min(screenY, size.height * 0.72))
        )
    }

    // MARK: - Bezier sampling

    // Evaluates the compound bezier at parameter t (0…segmentCount).
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

    // Finds the level curve's SVG-space Y at a given SVG-space X via linear interpolation
    // between densely-sampled bezier points. Also handles the final lineTo segment.
    private func levelY(atSvgX targetX: CGFloat) -> CGFloat? {
        let curves  = config.levelCurves
        let start   = config.levelStart
        let lineEnd = config.levelEnd
        let steps   = 300
        let segCount = CGFloat(curves.count)

        var prev = start
        for i in 1...steps {
            let t  = CGFloat(i) / CGFloat(steps) * segCount
            let pt = evalBezier(curves, start: start, t: t)
            if prev.x <= targetX && pt.x >= targetX {
                let dx = pt.x - prev.x
                let frac = dx == 0 ? 0.5 : (targetX - prev.x) / dx
                return prev.y + frac * (pt.y - prev.y)
            }
            prev = pt
        }

        // Final lineTo segment from last curve end to levelEnd
        if let lastEnd = curves.last?.end,
           lastEnd.x <= targetX, lineEnd.x >= targetX {
            let dx = lineEnd.x - lastEnd.x
            guard dx != 0 else { return lastEnd.y }
            return lastEnd.y + (targetX - lastEnd.x) / dx * (lineEnd.y - lastEnd.y)
        }
        return nil
    }

    // Returns the nearest x-axis label for the given SVG x coordinate.
    private func dateLabel(atSvgX x: CGFloat) -> String {
        let labels = config.xLabels
        guard labels.count > 1 else { return labels.first?.text ?? "" }
        for i in 0..<labels.count - 1 {
            if x >= labels[i].x && x <= labels[i + 1].x {
                let mid = (labels[i].x + labels[i + 1].x) / 2
                return x < mid ? labels[i].text : labels[i + 1].text
            }
        }
        return x < labels[0].x ? labels[0].text : labels[labels.count - 1].text
    }

    // MARK: - Static chart elements

    private var legend: some View {
        HStack(spacing: 16) {
            legendItem(color: theme.accent, dashed: false, label: "Level")
            legendItem(color: theme.chartAvgLine, dashed: true, label: "30-yr Avg")
            legendItem(color: Theme.neutral700, dashed: false, label: "Rainfall")
        }
        .font(AppFont.body(11, weight: .semibold))
        .foregroundStyle(theme.textMuted(0.6))
    }

    private func legendItem(color: Color, dashed: Bool, label: String) -> some View {
        HStack(spacing: 5) {
            Path { p in
                p.move(to: CGPoint(x: 0, y: 1.25))
                p.addLine(to: CGPoint(x: 14, y: 1.25))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2.5, dash: dashed ? [3, 2] : []))
            .frame(width: 14, height: 2.5)
            Text(label.uppercased()).tracking(0.3)
        }
    }

    private func gridlines(size: CGSize) -> some View {
        ZStack {
            gridline(y: 34,  label: "681", accent: true,  dashed: false, size: size)
            gridline(y: 90,  label: "660", accent: false, dashed: true,  size: size)
            gridline(y: 146, label: "640", accent: false, dashed: true,  size: size)
            gridline(y: 203, label: "620", accent: false, dashed: true,  size: size)
            gridline(y: 260, label: "605", accent: true,  dashed: false, size: size)
        }
    }

    private func gridline(y: CGFloat, label: String, accent: Bool, dashed: Bool, size: CGSize) -> some View {
        let start = scaledPoint(CGPoint(x: 40, y: y),    size: size)
        let end   = scaledPoint(CGPoint(x: 1000, y: y),  size: size)
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

    private func rainfall(size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(rainfallBars.enumerated()), id: \.offset) { _, bar in
                let rect = scaledRect(x: bar.x, y: bar.y, width: 8, height: bar.h, size: size)
                Rectangle()
                    .fill(theme.chartRainfall)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
        .opacity(0.45)
    }
}
