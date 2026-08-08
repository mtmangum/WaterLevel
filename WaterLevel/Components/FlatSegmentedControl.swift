//
//  FlatSegmentedControl.swift
//  WaterLevel
//
//  A flat, square-cornered segmented control (no native rounded pill),
//  matching the Modernist system's `.seg` component.
//

import SwiftUI

struct FlatSegmentedControl<T: Hashable>: View {
    let options: [T]
    let label: (T) -> String
    @Binding var selection: T
    let theme: Theme
    var fontSize: CGFloat = 12
    var expand: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    selection = option
                } label: {
                    Text(label(option))
                        .font(AppFont.body(fontSize, weight: .bold))
                        .tracking(0.3)
                        .foregroundStyle(selection == option ? theme.text : theme.textMuted(0.55))
                        .frame(maxWidth: expand ? .infinity : nil)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selection == option ? theme.surface : Color.clear)
                }
                .buttonStyle(.plain)

                if index < options.count - 1 {
                    Rectangle()
                        .fill(theme.divider)
                        .frame(width: 1)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .overlay(
            Rectangle()
                .strokeBorder(theme.divider, lineWidth: 1)
        )
    }
}
