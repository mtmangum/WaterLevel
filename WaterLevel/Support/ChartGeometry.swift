//
//  ChartGeometry.swift
//  WaterLevel
//
//  Shared helpers for translating SVG path data (1000-wide, 255-tall viewBox)
//  into scaled SwiftUI paths. Pass xRange/yRange to support zoom on either axis.
//

import SwiftUI

struct CubicSegment {
    let c1: CGPoint
    let c2: CGPoint
    let end: CGPoint
}

/// Builds a Path from SVG-style bezier data, scaled to `size`.
/// `xRange` and `yRange` define the visible SVG window (defaults = full view).
func svgPath(start: CGPoint,
             curves: [CubicSegment],
             lineTo: CGPoint? = nil,
             size: CGSize,
             xRange: ClosedRange<CGFloat> = 0...1000,
             yRange: ClosedRange<CGFloat> = 0...255) -> Path {
    let sx = size.width  / (xRange.upperBound - xRange.lowerBound)
    let sy = size.height / (yRange.upperBound - yRange.lowerBound)
    func p(_ pt: CGPoint) -> CGPoint {
        CGPoint(x: (pt.x - xRange.lowerBound) * sx,
                y: (pt.y - yRange.lowerBound) * sy)
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
                 xRange: ClosedRange<CGFloat> = 0...1000,
                 yRange: ClosedRange<CGFloat> = 0...255) -> CGPoint {
    let sx = size.width  / (xRange.upperBound - xRange.lowerBound)
    let sy = size.height / (yRange.upperBound - yRange.lowerBound)
    return CGPoint(x: (pt.x - xRange.lowerBound) * sx,
                   y: (pt.y - yRange.lowerBound) * sy)
}

func scaledRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat,
                size: CGSize,
                xRange: ClosedRange<CGFloat> = 0...1000,
                yRange: ClosedRange<CGFloat> = 0...255) -> CGRect {
    let sx = size.width  / (xRange.upperBound - xRange.lowerBound)
    let sy = size.height / (yRange.upperBound - yRange.lowerBound)
    return CGRect(x: (x - xRange.lowerBound) * sx,
                  y: (y - yRange.lowerBound) * sy,
                  width: width * sx, height: height * sy)
}
