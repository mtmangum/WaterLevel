//
//  DashboardView.swift
//  WaterLevel
//

import SwiftUI

struct DashboardView: View {
    let theme: Theme
    let range: RangeOption

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StatGridView(theme: theme)
            DashboardChartCard(theme: theme, range: range)
        }
    }
}
