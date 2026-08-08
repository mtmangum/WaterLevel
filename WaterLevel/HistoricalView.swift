//
//  HistoricalView.swift
//  WaterLevel
//

import SwiftUI

struct HistoricalView: View {
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HistoricalChartCard(theme: theme)
            HistoricalTableView(theme: theme)
        }
    }
}
