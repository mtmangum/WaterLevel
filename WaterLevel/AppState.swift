//
//  AppState.swift
//  WaterLevel
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var isDark: Bool = true
    @Published var readings: [DailyReading] = []          // last 1 year
    @Published var historicalReadings: [DailyReading] = [] // full history
    @Published var isLoadingData = false
    @Published var dataError: String?
    @Published var lastUpdated: Date?

    var theme: Theme { Theme(isDark: isDark) }

    var latestReading: DailyReading? { readings.last }

    // Net daily storage change converted to cfs (1 AF/day = 0.504 cfs)
    var dailyNetCfs: Double? {
        guard readings.count >= 2 else { return nil }
        let delta = readings[readings.count - 1].storage - readings[readings.count - 2].storage
        return delta * 0.504
    }

    // Average water level for the current month across the last 30 years
    var thirtyYearAvgLevel: Double? {
        guard !historicalReadings.isEmpty else { return nil }
        let currentYear  = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let cutoff = currentYear - 30
        let relevant = historicalReadings.filter {
            $0.year >= cutoff && $0.year < currentYear && $0.month == currentMonth
        }
        guard !relevant.isEmpty else { return nil }
        return relevant.map(\.waterLevel).reduce(0, +) / Double(relevant.count)
    }

    func fetchData() async {
        await MainActor.run { isLoadingData = true }
        do {
            // Fetch 1-year (fast) and full history (slower) in parallel
            async let recent      = LakeDataService.shared.fetchReadings()
            async let historical  = LakeDataService.shared.fetchAllReadings()
            let (r, h) = try await (recent, historical)
            await MainActor.run {
                readings           = r
                historicalReadings = h
                lastUpdated        = Date()
                isLoadingData      = false
            }
        } catch {
            await MainActor.run {
                dataError     = error.localizedDescription
                isLoadingData = false
            }
        }
    }
}
