//
//  AppState.swift
//  WaterLevel
//

import SwiftUI
import Combine

enum RangeOption: String, CaseIterable, Identifiable {
    case oneMonth = "1M"
    case oneYear = "1Y"
    case fiveYear = "5Y"
    case all = "ALL"

    var id: String { rawValue }
}

final class AppState: ObservableObject {
    @Published var range: RangeOption = .oneYear
    @Published var isDark: Bool = true

    var theme: Theme { Theme(isDark: isDark) }
}
