//
//  ChartGeometry.swift
//  WaterLevel
//
//  Shared helpers for translating SVG path data (1000-wide, 255-tall viewBox)
//  into scaled SwiftUI paths. Pass xRange to support horizontal zoom.
//

import SwiftUI

struct CubicSegment {
    let c1: CGPoint
    let c2: CGPoint
    let end: CGPoint
}

/// Builds a Path from SVG-style bezier data, scaled to `size`.
/// `xRange` defines the visible SVG x window (default full 0…1000).
func svgPath(start: CGPoint,
             curves: [CubicSegment],
             lineTo: CGPoint? = nil,
             size: CGSize,
             xRange: ClosedRange<CGFloat> = 0...1000) -> Path {
    let xSpan = xRange.upperBound - xRange.lowerBound
    let sx = size.width / xSpan
    let sy = size.height / 255
    func p(_ pt: CGPoint) -> CGPoint {
        CGPoint(x: (pt.x - xRange.lowerBound) * sx, y: pt.y * sy)
    }
    var path = Path()
    path.move(to: p(start))
    for c in curves {
        path.addCurve(to: p(c.end), control1: p(c.c1), control2: p(c.c2))
    }
    if let lineTo { path.addLine(to: p(lineTo)) }
    return path
}

func scaledPoint(_ pt: CGPoint,
                 size: CGSize,
                 xRange: ClosedRange<CGFloat> = 0...1000) -> CGPoint {
    let sx = size.width / (xRange.upperBound - xRange.lowerBound)
    let sy = size.height / 255
    return CGPoint(x: (pt.x - xRange.lowerBound) * sx, y: pt.y * sy)
}

func scaledRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat,
                size: CGSize,
                xRange: ClosedRange<CGFloat> = 0...1000) -> CGRect {
    let sx = size.width / (xRange.upperBound - xRange.lowerBound)
    let sy = size.height / 255
    return CGRect(x: (x - xRange.lowerBound) * sx, y: y * sy,
                  width: width * sx, height: height * sy)
}
