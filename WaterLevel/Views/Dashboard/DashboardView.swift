//
//  DashboardView.swift
//  WaterLevel
//

import SwiftUI

struct DashboardView: View {
    let theme: Theme

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 12) {
                StatGridView(theme: theme)
                    .frame(height: geo.size.height / 4)
                DashboardChartCard(theme: theme)
                    .frame(height: geo.size.height * 3 / 4 - 12)
            }
        }
    }
}
