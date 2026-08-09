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
    func fetchReadings() async throws -> [DailyReading] {
        return try await fetch(suffix: "-1year")
    }

    // Returns full historical record (since 1940), sorted oldest → newest.
    func fetchAllReadings() async throws -> [DailyReading] {
        return try await fetch(suffix: "")
    }

    // Reads cached readings from the previous network fetch (no network required).
    func cachedReadings() -> [DailyReading]? { loadCache(suffix: "-1year") }
    func cachedAllReadings() -> [DailyReading]? { loadCache(suffix: "") }

    private func fetch(suffix: String) async throws -> [DailyReading] {
        let url = URL(string: "https://waterdatafortexas.org/reservoirs/individual/travis\(suffix).csv")!
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let csv = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        writeCache(csv, suffix: suffix)
        return parseCSV(csv)
    }

    // MARK: - Cache

    private func cacheURL(suffix: String) -> URL? {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory,
                                                  in: .userDomainMask).first else { return nil }
        let dir = base.appendingPathComponent("WaterLevel")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("travis\(suffix).csv")
    }

    private func writeCache(_ csv: String, suffix: String) {
        guard let url = cacheURL(suffix: suffix) else { return }
        try? csv.write(to: url, atomically: true, encoding: .utf8)
    }

    private func loadCache(suffix: String) -> [DailyReading]? {
        guard let url = cacheURL(suffix: suffix),
              let csv = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        let result = parseCSV(csv)
        return result.isEmpty ? nil : result
    }

    private func parseCSV(_ csv: String) -> [DailyReading] {
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
