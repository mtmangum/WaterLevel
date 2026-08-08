//
//  ChartGeometry.swift
//  WaterLevel
//
//  Shared helpers for translating the mock's SVG path data (1000x320 viewBox)
//  into scaled SwiftUI Canvas paths.
//

import SwiftUI

struct CubicSegment {
    let c1: CGPoint
    let c2: CGPoint
    let end: CGPoint
}

/// Builds a Path from SVG-style "M start C c1 c2 end C ... L lineTo" data,
/// scaled from the 1000x320 viewBox to `size`.
func svgPath(start: CGPoint, curves: [CubicSegment], lineTo: CGPoint? = nil, size: CGSize) -> Path {
    let sx = size.width / 1000
    let sy = size.height / 320
    func p(_ pt: CGPoint) -> CGPoint { CGPoint(x: pt.x * sx, y: pt.y * sy) }

    var path = Path()
    path.move(to: p(start))
    for c in curves {
        path.addCurve(to: p(c.end), control1: p(c.c1), control2: p(c.c2))
    }
    if let lineTo {
        path.addLine(to: p(lineTo))
    }
    return path
}

func scaledPoint(_ pt: CGPoint, size: CGSize) -> CGPoint {
    CGPoint(x: pt.x * size.width / 1000, y: pt.y * size.height / 320)
}

func scaledRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, size: CGSize) -> CGRect {
    let sx = size.width / 1000
    let sy = size.height / 320
    return CGRect(x: x * sx, y: y * sy, width: width * sx, height: height * sy)
}
