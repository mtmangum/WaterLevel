//
//  AppState.swift
//  WaterLevel
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var isDark: Bool = true
    @Published var readings: [DailyReading] = []           // last 1 year
    @Published var historicalReadings: [DailyReading] = [] // full history

    /// Monthly averages for the 30-yr avg chart line (computed once on load)
    @Published var thirtyYearMonthlyAvgs: [(month: Int, level: Double)] = []
    /// Actual daily readings per year for the historical chart lines 2022–2025
    @Published var chartYearDailyReadings: [Int: [DailyReading]] = [:]

    @Published var isLoadingData = false
    @Published var dataError: String?
    @Published var lastUpdated: Date?

    var theme: Theme { Theme(isDark: isDark) }
    var latestReading: DailyReading? { readings.last }

    // Net daily storage change converted to cfs (1 AF/day ≈ 0.504 cfs)
    var dailyNetCfs: Double? {
        guard readings.count >= 2 else { return nil }
        let delta = readings[readings.count - 1].storage - readings[readings.count - 2].storage
        return delta * 0.504
    }

    // Average water level for the current month from the pre-computed 30-yr averages
    var thirtyYearAvgLevel: Double? {
        let currentMonth = Calendar.current.component(.month, from: Date())
        return thirtyYearMonthlyAvgs.first(where: { $0.month == currentMonth })?.level
    }

    func fetchData() async {
        // Phase 1: restore cached data immediately so the chart is never empty on relaunch
        let cachedR = await LakeDataService.shared.cachedReadings()
        let cachedH = await LakeDataService.shared.cachedAllReadings()
        if let r = cachedR, let h = cachedH {
            let (avgs, yearMap) = Self.derivedData(r: r, h: h)
            await MainActor.run {
                readings               = r
                historicalReadings     = h
                thirtyYearMonthlyAvgs  = avgs
                chartYearDailyReadings = yearMap
            }
        }

        // Phase 2: fetch fresh data from the network
        await MainActor.run { isLoadingData = true }
        do {
            async let recent     = LakeDataService.shared.fetchReadings()
            async let historical = LakeDataService.shared.fetchAllReadings()
            let (r, h) = try await (recent, historical)
            let (avgs, yearMap) = Self.derivedData(r: r, h: h)
            await MainActor.run {
                readings               = r
                historicalReadings     = h
                thirtyYearMonthlyAvgs  = avgs
                chartYearDailyReadings = yearMap
                lastUpdated            = Date()
                isLoadingData          = false
            }
        } catch {
            await MainActor.run {
                dataError     = error.localizedDescription
                isLoadingData = false
            }
        }
    }

    private static func derivedData(r: [DailyReading], h: [DailyReading])
        -> (avgs: [(month: Int, level: Double)], yearMap: [Int: [DailyReading]]) {
        let currentYear = Calendar.current.component(.year, from: Date())
        let cutoff = currentYear - 30
        let relevant = h.filter { $0.year >= cutoff && $0.year < currentYear }
        let avgs: [(month: Int, level: Double)] = (1...12).compactMap { month in
            let monthly = relevant.filter { $0.month == month }
            guard !monthly.isEmpty else { return nil }
            return (month, monthly.map(\.waterLevel).reduce(0, +) / Double(monthly.count))
        }
        var yearMap: [Int: [DailyReading]] = [:]
        for year in [2022, 2023, 2024, 2025] {
            let yr = h.filter { $0.year == year }
            if !yr.isEmpty { yearMap[year] = yr }
        }
        return (avgs, yearMap)
    }
}
