//
//  AppState.swift
//  WaterLevel
//

import SwiftUI
import Combine

enum AppTab {
    case dashboard
    case historical
}

enum RangeOption: String, CaseIterable, Identifiable {
    case oneMonth = "1M"
    case oneYear = "1Y"
    case fiveYear = "5Y"
    case all = "ALL"

    var id: String { rawValue }
}

/// Root app state: current screen, chart range selection, and the light/dark
/// toggle that lives in the sidebar footer (drives the whole app, not system appearance).
final class AppState: ObservableObject {
    @Published var tab: AppTab = .dashboard
    @Published var range: RangeOption = .oneYear
    // Mock's default state is dark.
    @Published var isDark: Bool = true

    var theme: Theme { Theme(isDark: isDark) }
}
