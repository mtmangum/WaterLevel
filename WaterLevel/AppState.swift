//
//  AppState.swift
//  WaterLevel
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var isDark: Bool = true
    @Published var selectedLake: Lake = Lake.all.first(where: {
        $0.id == UserDefaults.standard.string(forKey: "selectedLakeID")
    }) ?? .travis
    @Published var readings: [DailyReading] = []           // last 1 year
    @Published var historicalReadings: [DailyReading] = [] // full history

    /// Monthly averages for the 30-yr avg chart line (computed once on load)
    @Published var thirtyYearMonthlyAvgs: [(month: Int, level: Double)] = []
    /// Actual daily readings per year for the historical chart lines 2022–2025
    @Published var chartYearDailyReadings: [Int: [DailyReading]] = [:]

    @Published var isLoadingData = false
    @Published var dataError: String?
    @Published var lastUpdated: Date?

    private var fetchGeneration = 0

    init() {
        // Load both caches synchronously so real data is present before the first frame renders.
        // Both CSVs parse in < 25 ms total — negligible on the main thread during init.
        if let r = LakeDataService.shared.cachedReadings(for: selectedLake),
           let h = LakeDataService.shared.cachedAllReadings(for: selectedLake) {
            let (avgs, yearMap) = Self.derivedData(r: r, h: h)
            readings               = r
            historicalReadings     = h
            thirtyYearMonthlyAvgs  = avgs
            chartYearDailyReadings = yearMap
        }
    }

    func selectLake(_ lake: Lake) {
        guard lake != selectedLake else { return }
        selectedLake = lake
        UserDefaults.standard.set(lake.id, forKey: "selectedLakeID")
        readings = []
        historicalReadings = []
        thirtyYearMonthlyAvgs = []
        chartYearDailyReadings = [:]
        lastUpdated = nil
        if let r = LakeDataService.shared.cachedReadings(for: lake),
           let h = LakeDataService.shared.cachedAllReadings(for: lake) {
            let (avgs, yearMap) = Self.derivedData(r: r, h: h)
            readings               = r
            historicalReadings     = h
            thirtyYearMonthlyAvgs  = avgs
            chartYearDailyReadings = yearMap
        }
        Task { await fetchData() }
    }

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

    func prefetchAllLakes() async {
        let currentID = selectedLake.id
        let others = Lake.all.filter { $0.id != currentID }
        await withTaskGroup(of: Void.self) { group in
            for lake in others {
                group.addTask {
                    _ = try? await LakeDataService.shared.fetchReadings(for: lake, maxAge: 3600)
                    _ = try? await LakeDataService.shared.fetchAllReadings(for: lake, maxAge: 6 * 3600)
                }
            }
        }
    }

    func fetchData() async {
        // Each call gets a unique generation. Results are only applied if no newer fetch
        // has started by the time we finish — prevents a slow/stale fetch from overwriting
        // data for a lake the user has already switched away from.
        let generation: Int = await MainActor.run {
            fetchGeneration += 1
            isLoadingData = true
            return fetchGeneration
        }
        do {
            let lake = selectedLake
            async let recent     = LakeDataService.shared.fetchReadings(for: lake)
            async let historical = LakeDataService.shared.fetchAllReadings(for: lake, maxAge: 6 * 3600)
            let (r, h) = try await (recent, historical)
            let (avgs, yearMap) = Self.derivedData(r: r, h: h)
            await MainActor.run {
                guard generation == fetchGeneration else { return }
                readings               = r
                historicalReadings     = h
                thirtyYearMonthlyAvgs  = avgs
                chartYearDailyReadings = yearMap
                lastUpdated            = Date()
                isLoadingData          = false
            }
        } catch {
            await MainActor.run {
                guard generation == fetchGeneration else { return }
                dataError     = error.localizedDescription
                isLoadingData = false
            }
        }
    }

    static func derivedData(r: [DailyReading], h: [DailyReading])
        -> (avgs: [(month: Int, level: Double)], yearMap: [Int: [DailyReading]]) {
        let currentYear = Calendar.current.component(.year, from: Date())
        let cutoff = currentYear - 30
        let relevant = h.filter { $0.year >= cutoff && $0.year < currentYear }
        let avgs: [(month: Int, level: Double)] = (1...12).compactMap { month in
            let monthly = relevant.filter { $0.month == month && $0.waterLevel > 0 && $0.percentFull > 0 }
            guard !monthly.isEmpty else { return nil }
            // Trimmed mean: drop the lowest 20% to reduce skew from maintenance drawdowns and data anomalies
            let sorted    = monthly.map(\.waterLevel).sorted()
            let trimCount = sorted.count / 5
            let trimmed   = sorted.dropFirst(trimCount)
            guard !trimmed.isEmpty else { return nil }
            return (month, trimmed.reduce(0, +) / Double(trimmed.count))
        }
        var yearMap: [Int: [DailyReading]] = [:]
        for year in [2022, 2023, 2024, 2025] {
            let yr = h.filter { $0.year == year }
            if !yr.isEmpty { yearMap[year] = yr }
        }
        return (avgs, yearMap)
    }
}
