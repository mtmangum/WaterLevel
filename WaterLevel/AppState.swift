//
//  AppState.swift
//  WaterLevel
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var isDark: Bool = true

    var theme: Theme { Theme(isDark: isDark) }
}
