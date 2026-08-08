//
//  Tag.swift
//  WaterLevel
//
//  Square (zero-radius) chip used for the full-pool badge and year legends.
//

import SwiftUI

enum TagStyle {
    case accent
    case neutral
    case outline
}

struct Tag: View {
    let text: String
    let style: TagStyle
    let theme: Theme

    var body: some View {
        Text(text)
            .font(AppFont.body(10.5, weight: .bold))
            .tracking(0.4)
            .textCase(.uppercase)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(foreground)
            .background(background)
            .overlay(
                Rectangle().strokeBorder(style == .outline ? theme.textMuted(0.4) : .clear, lineWidth: 1)
            )
    }

    private var foreground: Color {
        switch style {
        case .accent: theme.chipAccentText
        case .neutral: theme.chipNeutralText
        case .outline: theme.textMuted(0.6)
        }
    }

    private var background: Color {
        switch style {
        case .accent: theme.chipAccentBg
        case .neutral: theme.chipNeutralBg
        case .outline: .clear
        }
    }
}
