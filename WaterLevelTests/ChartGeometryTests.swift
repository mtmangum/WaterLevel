import Testing
import CoreGraphics
@testable import WaterLevel

@Suite("Chart coordinate math")
struct ChartGeometryTests {

    // Full pool (681 ft) maps to SVG y = 34
    @Test func fullPoolToSvgY() {
        #expect(ftToSvgY(681.0) == 34.0)
    }

    // Low threshold (605 ft) maps to SVG y = 226
    @Test func lowThresholdToSvgY() {
        #expect(ftToSvgY(605.0) == 226.0)
    }

    // SVG y = 34 → 681 ft
    @Test func svgYTopToFt() {
        #expect(svgYToFt(34.0) == 681.0)
    }

    // SVG y = 226 → 605 ft
    @Test func svgYBottomToFt() {
        #expect(svgYToFt(226.0) == 605.0)
    }

    // Round-trip: ft → svgY → ft should be lossless
    @Test(arguments: [605.0, 630.0, 650.0, 670.0, 681.0])
    func roundTrip(ft: Double) {
        let result = svgYToFt(ftToSvgY(ft))
        #expect(abs(result - ft) < 0.0001)
    }

    // Jan = x 40, each month adds 80 SVG units
    @Test func monthToSvgXJan() {
        #expect(monthToSvgX(1) == CGFloat(40))
    }

    @Test func monthToSvgXDec() {
        #expect(monthToSvgX(12) == CGFloat(920))  // 40 + 11*80
    }

    @Test func monthSpacing() {
        let feb = monthToSvgX(2)
        let jan = monthToSvgX(1)
        #expect(feb - jan == CGFloat(80))
    }
}
