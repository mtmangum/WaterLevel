import Testing
@testable import WaterLevel

@Suite("CSV parsing")
struct LakeDataServiceTests {

    let service = LakeDataService.shared

    // A realistic CSV snippet (header + 2 data rows + a comment)
    private let sampleCSV = """
    # LCRA reservoir data
    date,water_level,surface_area,reservoir_storage,conservation_storage,percent_full
    2026-07-01,679.5,18432.0,1621234.0,1598123.0,93.2
    2026-07-02,679.8,18450.0,1625001.0,1601000.0,93.4
    """

    @Test func parsesCorrectRowCount() {
        let readings = service.parseCSV(sampleCSV)
        #expect(readings.count == 2)
    }

    @Test func parsesWaterLevel() {
        let readings = service.parseCSV(sampleCSV)
        #expect(readings[0].waterLevel == 679.5)
        #expect(readings[1].waterLevel == 679.8)
    }

    @Test func parsesDateComponents() {
        let readings = service.parseCSV(sampleCSV)
        #expect(readings[0].year  == 2026)
        #expect(readings[0].month == 7)
        #expect(readings[0].day   == 1)
    }

    @Test func parsesPercentFull() {
        let readings = service.parseCSV(sampleCSV)
        #expect(abs(readings[0].percentFull - 93.2) < 0.001)
    }

    @Test func parsesConservationStorage() {
        let readings = service.parseCSV(sampleCSV)
        #expect(readings[0].storage == 1_598_123.0)
    }

    @Test func skipsCommentLines() {
        let csv = "# comment\ndate,water_level,surface_area,reservoir_storage,conservation_storage,percent_full\n2026-01-01,670.0,17000.0,1500000.0,1480000.0,86.0\n"
        let readings = service.parseCSV(csv)
        #expect(readings.count == 1)
    }

    @Test func skipsHeaderRow() {
        let readings = service.parseCSV(sampleCSV)
        // Neither row should have year=0 (which would indicate a header was misread as data)
        #expect(readings.allSatisfy { $0.year > 0 })
    }

    @Test func skipsInvalidRows() {
        let csv = "2026-01-01,notanumber,17000.0,1500000.0,1480000.0,86.0\n"
        let readings = service.parseCSV(csv)
        #expect(readings.isEmpty)
    }

    @Test func sortedOldestFirst() {
        let readings = service.parseCSV(sampleCSV)
        #expect(readings[0].day < readings[1].day)
    }

    @Test func emptyCSVReturnsEmpty() {
        #expect(service.parseCSV("").isEmpty)
    }
}
