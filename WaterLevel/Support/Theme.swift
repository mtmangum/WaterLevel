//
//  Theme.swift
//  WaterLevel
//
//  Modernist design system tokens, translated from the design handoff.
//

import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

/// Colors and type ramps for the "Modernist" system: flat, mono red-on-white/black,
/// zero corner radius. Values from the handoff's `theme.json` token set.
struct Theme {
    let isDark: Bool

    static let accent = Color(hex: 0xEC3013)
    static let water  = Color(hex: 0x2B82D4)
    static let accent100 = Color(hex: 0xFFF2EF)
    static let accent200 = Color(hex: 0xFFDBD3)
    static let accent800 = Color(hex: 0x7A2415)
    static let accent900 = Color(hex: 0x4D170E)

    static let neutral100 = Color(hex: 0xF8F4F4)
    static let neutral200 = Color(hex: 0xEAE7E7)
    static let neutral300 = Color(hex: 0xD7D3D3)
    static let neutral400 = Color(hex: 0xBAB6B6)
    static let neutral500 = Color(hex: 0x9B9797)
    static let neutral600 = Color(hex: 0x7D7979)
    static let neutral700 = Color(hex: 0x605D5D)
    static let neutral800 = Color(hex: 0x444141)
    static let neutral900 = Color(hex: 0x2D2B2B)

    private static let lightBg = Color(hex: 0xF3F2F2)
    private static let lightSurface = Color(hex: 0xEAE9E9)
    private static let lightText = Color(hex: 0x201E1D)

    var background: Color { isDark ? Theme.neutral900 : Theme.lightBg }
    var surface: Color { isDark ? Theme.neutral800 : Theme.lightSurface }
    var text: Color { isDark ? Theme.neutral100 : Theme.lightText }

    /// text color at 40% opacity (light) / neutral-100 at 30% (dark), per handoff.
    var divider: Color { isDark ? Theme.neutral100.opacity(0.3) : text.opacity(0.4) }

    var accent: Color { Theme.accent }

    // Tag-chip pairing flips in dark mode; the accent itself never changes.
    var chipAccentBg: Color { isDark ? Theme.accent900 : Theme.accent100 }
    var chipAccentText: Color { isDark ? Theme.accent200 : Theme.accent800 }

    var chipNeutralBg: Color { isDark ? Theme.neutral700 : Theme.neutral200 }
    var chipNeutralText: Color { text.opacity(0.75) }

    var chartAvgLine: Color { Theme.neutral400 }
    var chartRainfall: Color { Theme.neutral500 }

    func textMuted(_ opacity: Double) -> Color { text.opacity(opacity) }
}

/// Archivo (Google Fonts) is the source-of-truth family; substituting the system
/// Heavy/Bold face per the handoff's documented fallback since Archivo isn't bundled.
enum AppFont {
    static func heading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .default)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

enum Spacing {
    static let s4: CGFloat = 4
    static let s8: CGFloat = 8
    static let s12: CGFloat = 12
    static let s16: CGFloat = 16
    static let s24: CGFloat = 24
    static let s32: CGFloat = 32
}
