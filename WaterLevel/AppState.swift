//
//  AppState.swift
//  WaterLevel
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var isDark: Bool = true
    @Published var readings: [DailyReading] = []
    @Published var isLoadingData = false
    @Published var dataError: String?
    @Published var lastUpdated: Date?

    var theme: Theme { Theme(isDark: isDark) }

    // Most recent available reading (CSV is sorted oldest → newest)
    var latestReading: DailyReading? { readings.last }

    func fetchData() async {
        await MainActor.run { isLoadingData = true }
        do {
            let fetched = try await LakeDataService.shared.fetchReadings()
            await MainActor.run {
                readings    = fetched
                lastUpdated = Date()
                isLoadingData = false
            }
        } catch {
            await MainActor.run {
                dataError     = error.localizedDescription
                isLoadingData = false
            }
        }
    }
}
