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
    // Used for 30-year average computation.
    func fetchAllReadings() async throws -> [DailyReading] {
        return try await fetch(suffix: "")
    }

    private func fetch(suffix: String) async throws -> [DailyReading] {
        let url = URL(string: "https://waterdatafortexas.org/reservoirs/individual/travis\(suffix).csv")!
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let csv = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        return parseCSV(csv)
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
            let storage = fields.count >= 5 ? (Double(fields[4]) ?? 0) : 0
            result.append(DailyReading(date: date, year: year, month: month, waterLevel: level, percentFull: pct, storage: storage))
        }
        return result.sorted { $0.date < $1.date }
    }
}
