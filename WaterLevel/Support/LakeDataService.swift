//
//  LakeDataService.swift
//  WaterLevel
//
//  Fetches daily lake level readings from waterdatafortexas.org.
//  CSV format: date,water_level,surface_area,reservoir_storage,
//              conservation_storage,percent_full,...
//

import Foundation

struct DailyReading {
    let date: Date
    let year: Int
    let month: Int              // 1–12
    let day: Int                // 1–31
    let waterLevel: Double      // feet above datum
    let percentFull: Double     // 0–100
    let storage: Double         // acre-feet (conservation_storage)
}

actor LakeDataService {
    static let shared = LakeDataService()
    private init() {}

    private static let csvDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(abbreviation: "UTC")
        return f
    }()

    // Returns the last year of daily readings, sorted oldest → newest.
    func fetchReadings(for lake: Lake) async throws -> [DailyReading] {
        return try await fetch(lake: lake, suffix: "-1year")
    }

    // Returns full historical record (since 1940), sorted oldest → newest.
    func fetchAllReadings(for lake: Lake) async throws -> [DailyReading] {
        return try await fetch(lake: lake, suffix: "")
    }

    // Reads cached readings synchronously (no actor hop, no await required).
    nonisolated func cachedReadings(for lake: Lake) -> [DailyReading]? { loadCache(lake: lake, suffix: "-1year") }
    nonisolated func cachedAllReadings(for lake: Lake) -> [DailyReading]? { loadCache(lake: lake, suffix: "") }

    private func fetch(lake: Lake, suffix: String) async throws -> [DailyReading] {
        let url = URL(string: "https://waterdatafortexas.org/reservoirs/individual/\(lake.id)\(suffix).csv")!
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        guard let csv = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        let readings = parseCSV(csv)
        guard !readings.isEmpty else {
            throw URLError(.cannotParseResponse)
        }
        writeCache(csv, lake: lake, suffix: suffix)
        return readings
    }

    // MARK: - Cache

    nonisolated private func cacheURL(lake: Lake, suffix: String) -> URL? {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory,
                                                  in: .userDomainMask).first else { return nil }
        let dir = base.appendingPathComponent("WaterLevel")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("\(lake.id)\(suffix).csv")
    }

    nonisolated private func writeCache(_ csv: String, lake: Lake, suffix: String) {
        guard let url = cacheURL(lake: lake, suffix: suffix) else { return }
        try? csv.write(to: url, atomically: true, encoding: .utf8)
    }

    nonisolated private func loadCache(lake: Lake, suffix: String) -> [DailyReading]? {
        guard let url = cacheURL(lake: lake, suffix: suffix),
              let csv = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        let result = parseCSV(csv)
        return result.isEmpty ? nil : result
    }

    nonisolated func parseCSV(_ csv: String) -> [DailyReading] {
        var result: [DailyReading] = []
        for line in csv.components(separatedBy: "\n") {
            let t = line.trimmingCharacters(in: .whitespaces)
            // Skip comment lines, blank lines, and the header row
            guard !t.isEmpty, !t.hasPrefix("#"), !t.hasPrefix("date") else { continue }
            let fields = t.components(separatedBy: ",")
            guard fields.count >= 6,
                  let date    = Self.csvDateFormatter.date(from: fields[0]),
                  let level   = Double(fields[1]),
                  let pct     = Double(fields[5]) else { continue }
            // Extract year/month directly from the date string to avoid timezone shifts
            let parts   = fields[0].split(separator: "-")
            let year    = parts.count >= 1 ? (Int(parts[0]) ?? 0) : 0
            let month   = parts.count >= 2 ? (Int(parts[1]) ?? 0) : 0
            let day     = parts.count >= 3 ? (Int(parts[2]) ?? 0) : 0
            let storage = fields.count >= 5 ? (Double(fields[4]) ?? 0) : 0
            result.append(DailyReading(date: date, year: year, month: month, day: day, waterLevel: level, percentFull: pct, storage: storage))
        }
        return result.sorted { $0.date < $1.date }
    }
}
