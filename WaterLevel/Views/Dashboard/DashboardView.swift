//
//  DashboardView.swift
//  WaterLevel
//

import SwiftUI

struct DashboardView: View {
    let theme: Theme

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                StatGridView(theme: theme)
                    .frame(height: geo.size.height / 4)
                Rectangle().fill(theme.divider).frame(height: 1)
                DashboardChartCard(theme: theme)
                    .frame(height: geo.size.height * 3 / 4 - 1)
            }
        }
    }
}
