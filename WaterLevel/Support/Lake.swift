//
//  Lake.swift
//  WaterLevel

import CoreGraphics

struct Lake: Identifiable, Equatable {
    let id: String            // waterdatafortexas.org URL slug + cache key
    let name: String          // ALL-CAPS display name
    let location: String      // e.g. "AUSTIN, TX"
    let fullPool: Double      // ft MSL (conservation pool elevation)
    let lowThreshold: Double  // ft MSL used as lower chart anchor

    // Convert between lake-level ft and the shared SVG y-axis.
    // Invariant: svgY 34 = fullPool, svgY 226 = lowThreshold (192 unit span).
    func ftToSvgY(_ ft: Double) -> CGFloat {
        let span = fullPool - lowThreshold
        return 34.0 + CGFloat(fullPool - ft) * (192.0 / span)
    }

    func svgYToFt(_ svgY: CGFloat) -> Double {
        let span = fullPool - lowThreshold
        return fullPool - Double(svgY - 34.0) * (span / 192.0)
    }

    static let all: [Lake] = [
        Lake(id: "buchanan",    name: "LAKE BUCHANAN",     location: "BURNET COUNTY, TX", fullPool: 1020.5, lowThreshold: 920.0),
        Lake(id: "inks",        name: "LAKE INKS",         location: "BURNET COUNTY, TX", fullPool: 888.25, lowThreshold: 848.0),
        Lake(id: "lyndon-b-johnson", name: "LAKE LBJ",          location: "LLANO COUNTY, TX",  fullPool: 824.0, lowThreshold: 790.0),
        Lake(id: "marble-falls",    name: "LAKE MARBLE FALLS", location: "BURNET COUNTY, TX", fullPool: 738.5, lowThreshold: 710.0),
        Lake(id: "travis",      name: "LAKE TRAVIS",       location: "AUSTIN, TX",        fullPool: 681.0,  lowThreshold: 605.0),
        Lake(id: "austin",      name: "LAKE AUSTIN",       location: "AUSTIN, TX",        fullPool: 492.0,  lowThreshold: 460.0),
    ]

    static let travis = all.first(where: { $0.id == "travis" })!
}
