# Changelog

All notable changes to WaterLevel are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Fixed
- **Gridlines running behind y-axis labels** — dashed gridlines started at the chart's left edge (x=0), the same position as the overlaid y-axis numbers, so lines ran directly through the label text. Gridlines now start after the label column when the axis is shown.

## [1.0.0] — 2026-08-10

### Fixed
- **Chart y-axis overlay** — y-axis labels now overlay the left edge of the plot instead of reserving a separate gutter column, so the chart uses the full available width; on phone-width screens the axis numbers are hidden entirely rather than squeezed into a narrow column.
- **Netlify CSV proxy function crashing (502)** — `lake-csv.js` used CommonJS `exports.handler` while `package.json` declares `"type": "module"`, so Node refused to load it, breaking all chart data on the deployed site. Converted to `export async function handler(event)`.
- **Chart legend overflow on mobile** — the "WATER LEVEL" title + year-toggle legend (2026/2025/2024/2023/2022/30-YR AVG) shared one non-wrapping row, so on phone widths only the first two legend badges were visible/tappable and the rest overflowed off-screen. Row now wraps, with the legend dropping to its own line under 640px.
- **Chart left-alignment at all sizes** — the "WATER LEVEL" title/legend row was pinned to the plot's y-axis gutter width instead of the stat grid's own inset, leaving the chart visibly indented past "OUTFLOW" and the other stat cells at every screen size, not just mobile. Title/legend now matches the stat grid's padding directly (16px desktop, 12px under 640px) independent of the y-axis gutter, and the gutter itself narrowed (44→36px desktop, 30px on phone-width charts) to tighten the plot's left edge too — it can't fully match the stat grid's inset without clipping 4-digit lake elevations, but it's much closer.

### Changed
- **Mobile-responsive web layout** — removed the hard-coded 860px minimum width that forced horizontal scrolling on phones. Header now wraps into two rows under 640px (title/picker, then actions spaced edge-to-edge). Stat grid collapses from a 4-across row into a 2×2 grid. Annual Summary panel becomes a full-screen sheet with a visible close button (previously only closable via backdrop click, unreachable once full-screen) and its table scrolls horizontally instead of squeezing five columns unreadably narrow. Chart now handles touch events (tap for tooltip, drag for zoom) alongside the existing mouse handlers, with `touch-action: none` so gestures don't fight page scrolling.

### Added
- **Web favicon** — SVG favicon matching the native app icon's water-level wave + marker dot motif and color palette (`web/public/favicon.svg`).

### Changed
- **Adaptive x-axis date labels** — chart x-axis granularity now scales with zoom level: monthly labels at full view, then bi-weekly → every 10 days → weekly → every 3 days → every 2 days → daily as the user zooms in. Labels in sub-monthly views use "MMM D" format (e.g. "JAN 15") at a slightly smaller size so context is always visible.
- **Crosshair tooltip y-tracking** — tooltip now follows the cursor vertically (clamped to stay on canvas) instead of being fixed at a hardcoded y position. Horizontal offset increased from 80 to 90pt to clear the cursor and dots.

### Added
- **All six Highland Lakes** — lake picker ("LAKE ▾") in the header lets users switch between Lake Buchanan, Lake Inks, Lake LBJ, Lake Marble Falls, Lake Travis, and Lake Austin. Each lake fetches its own CSV from waterdatafortexas.org, maintains its own disk cache, and scales the chart Y-axis to its full pool / low-threshold range.
- **`Lake` struct** (`Lake.swift`) — encapsulates id (URL slug), display name, location, full pool ft, and low-threshold ft. Includes per-lake `ftToSvgY` / `svgYToFt` coordinate helpers so the chart renders correctly at any elevation range.
- **Hourly auto-refresh** — the app re-fetches data every hour while running, keeping the "SYNCED X AGO" label current and picking up LCRA's daily CSV update automatically.
- **Live Annual Summary table** — `HistoricalTableView` now computes min / max / avg / year-end % full from `historicalReadings` for the current lake instead of showing hardcoded Travis figures.

### Changed
- **App display name** renamed to **LakeLevel** (`CFBundleDisplayName`, `PRODUCT_NAME`). The dock, Cmd+Tab switcher, and About menu all reflect the new name; Xcode project and source files retain their original names.
- **Gridline labels** for 4-digit elevations (≥ 1000 ft, e.g. Buchanan) format as integers to avoid clipping; label x-position is now centered in the available left margin rather than hardcoded at 14 pt.
- **Stat value display** — current level ≥ 1000 ft drops the decimal (e.g. "1020 ft" not "1020.5 ft"); `minimumScaleFactor(0.75)` added as a safety net for all stat values.
- **Travis placeholder curve removed** — switching to a lake with no cached data shows an empty chart and loading state rather than a Travis-shaped ghost curve.

### Added
- **Unit tests** — 23 tests using Swift Testing framework covering CSV parsing (`LakeDataServiceTests`), coordinate math (`ChartGeometryTests`), and boilerplate. All pass.
- **`ChartGeometry` coordinate helpers** — `svgYToFt`, `ftToSvgY`, `monthToSvgX` promoted from private chart-file functions to internal module-level functions in `ChartGeometry.swift`, making them reusable and testable.

### Changed
- **UI simplification** — removed outer border boxes from stat grid and chart card; replaced with a single 1 px rule between the header and the stat row and another between the stat row and the chart. Vertical dividers between stat cells removed. Chart gridlines thinned (3 px dash, dimmer label color). Header loading shimmer now overlays the rule rather than replacing it.
- **App Sandbox disabled** for development builds on machines where the Personal Team certificate does not support the `network.client` entitlement; `WaterLevel.entitlements` reduced to `get-task-allow` only.

### Added
- **Real daily chart data** — all five year lines (2022–2026) now plot actual daily readings from the CSV via Catmull-Rom spline through 365 points, replacing fabricated static curves.
- **Disk cache** — after each successful network fetch, both CSV files are saved to `~/Library/Application Support/WaterLevel/`. On the next launch the chart renders immediately from cache before the network refresh completes, so the chart is never empty on relaunch.
- **Dynamic Y-axis scaling** — chart vertical range auto-adjusts to fit the visible data. Y bounds extended to 560–710 ft so the chart handles flood levels above full pool (681 ft) and drought lows below the old 600 ft floor. Gridlines use 10 ft steps for any span up to 150 ft.
- **Loading feedback** — animated shimmer bar replaces the header divider while data fetches; the status dot pulses while loading.
- **Stat grid contextual details** — each cell now shows a second line of context:
  - **CURRENT LEVEL** — X.X% full + ↑ Rising / ↓ Falling indicator (colored blue or red).
  - **INFLOW** — ±% vs yesterday when net inflow two days running; otherwise ↓ X cfs outbound when lake is losing storage.
  - **OUTFLOW** — "NET DAILY" label clarifying the figure is net.
  - **30-YR HISTORICAL AVG** (renamed from VS 30-YR AVG) — shows the actual historical average level in ft as context for the ± delta.
- **`WaterLevel.entitlements`** — `com.apple.security.network.client` entitlement added so the sandboxed app can make outbound HTTPS requests.
- **Header sync label** — shows "FETCHING DATA…" during load then "SYNCED JUST NOW / Xm AGO" from `AppState.lastUpdated`.

### Changed
- **Chart x-axis alignment** — January 1 now aligns exactly with the gridline left edge; month labels sit at the left edge of each month zone rather than being centered.
- **30-yr avg line** — extended to span Jan 1→Dec 31, matching the horizontal extent of the year lines.
- **Stat grid** — CAPACITY cell removed; its % full info moved into the CURRENT LEVEL detail row, now shown as "X.X% full". All cells use a consistent label + value + detail structure.
- **Top Y-axis label** — clamped to minimum 8pt from top edge so it never gets clipped.

### Removed
- `SidebarView.swift`, `HistoricalView.swift`, `HistoricalChartCard.swift` — dead code; sidebar was removed from the app and the historical chart card used fabricated static data.
- Unused static `chartAvgStart`/`chartAvgCurves`/`chartAvgEnd` constants (replaced by live `avgSeries` computed from `thirtyYearMonthlyAvgs`).

### Fixed
- **No flash of placeholder curves on launch** — both cache files (24 KB and 1.9 MB) are now parsed synchronously in `AppState.init()` (~21 ms total) before the first SwiftUI frame renders, so real data is always present from frame zero. The fabricated static year-line placeholders are removed entirely.
- **Network fetch no longer overwrites cached data with bad data** — `fetch()` now checks the HTTP status code (throws on non-200) and validates the parsed row count (throws if empty) before writing to disk or updating state. A server-side error or HTML response no longer silently replaces valid cached readings with an empty array.
- Chart lines no longer extend left of the gridlines or misalign with month labels.
- Year lines above 681 ft ("full pool") no longer go off-canvas — the upper Y clamp was raised from 682 ft to 710 ft.
- Year lines far below 640 ft no longer go off-canvas — the lower Y clamp was lowered from 600 ft to 560 ft.
- Date parsing: `DailyReading` now stores `day: Int` extracted directly from the CSV date string.

---

## [Previous Unreleased]

### Added
- **5-year Jan–Dec overlay chart** — 2022–2026 year lines plotted on a shared Jan–Dec axis, replacing the single trailing-12-month line and range picker. Each year is a distinct neutral tone; 2026 (current year) renders in `Theme.water` blue and ends at the current month with a filled dot.
- **Year toggle buttons in legend** — single-tap hides/shows a year; double-tap isolates that year (hides all others). Double-tapping an already-isolated year restores all lines.
- **Multi-year crosshair tooltip** — hover shows an interpolated level (ft) for every visible year at the cursor position, with a color swatch per row. Tooltip flips left when near the right edge.
- **Annual Summary popover** — header button opens a popover (arrowEdge: `.top`, minWidth 480) with the historical table, keeping the main layout uncluttered.
- **App icon** — dark `#2D2B2B` background, white water-level bezier curve, blue gradient fill below the curve, red endpoint dot with white ring. Sizes 16–1024 generated and registered in the asset catalog.
- **`Theme.water`** — `#2B82D4` static color token for the current-year line and crosshair accent.
- **Grouped file structure** — source files reorganized into `Views/Dashboard`, `Views/Historical`, `Components`, and `Support` groups.

### Changed
- **Header** — title is now "LAKE TRAVIS" (subtitle "WATER LEVEL MONITOR · AUSTIN, TX"). Live indicator and dark/light toggle moved to the header; sidebar and footer removed entirely.
- **Stat grid layout** — stats are 1/4 of the content height; chart is 3/4. Each stat cell stacks label → 22pt value → detail and scales to fill available width equally.
- **Chart proportions** — SVG viewBox height reduced from 320 to 255 units to eliminate dead space below the month labels (~7% padding vs. the previous ~26%).
- **2026 line color** — changed from accent red to `Theme.water` blue to distinguish the current year from UI chrome.
- **Tooltip background** — changed from `theme.surface` to `theme.background` so the neutral-800 (2022) swatch is visible in dark mode.
- **Month labels** — x-position calculated with `Int(x / 80)` directly so all 12 months appear smoothly under the crosshair (previously snapped every 2 months).
- **Year lines left edge** — all series start at SVG x=40 (matching the left gridline) rather than x=0, so lines no longer extend behind the y-axis labels.

### Removed
- Sidebar navigation and sidebar footer.
- Range picker (1M / 1Y / 5Y / ALL) — replaced by per-year toggles.
- Scrollable annual-summary section in the main layout — moved to popover.

### Fixed
- Tooltip ft values no longer fade — set to `theme.text` (was `theme.textMuted`).
- Crosshair vertical line now uses `Theme.water` at 45% opacity (was accent red).

---

## [0.1.0] — 2026-08-07

### Added
- Initial app: Dashboard and Historical Trends views with static placeholder data.
- Sidebar — navigation (Dashboard, Historical Trends, Alerts, Settings), brand block, Light / Dark mode toggle, live indicator.
- Dashboard stat grid — Current Level, Inflow, Outflow, VS Historical Avg cells divided by 2px rules.
- Dashboard chart — 12-month trailing level line (accent red), 30-yr average (dashed neutral), daily rainfall bars; gridlines at 605 ft (low threshold) and 681 ft (full pool) in accent red.
- Historical chart — four lines (2024, 2025, 2026, 30-yr avg) on a Jan–Dec axis.
- Historical data table — Min / Max / Avg / Year-end % full for 2022–2026 YTD.
- Modernist design system (`Theme.swift`) — accent `#EC3013`, neutral ramp 100–900, zero corner radius, 2px dividers, Spacing scale.
- `FlatSegmentedControl` — square-cornered segmented toggle used for range selector and Light / Dark switch.
- `Tag` — square chip in accent, neutral, or outline style; dark-mode chip pairing flips per spec.
- Native macOS window — transparent titlebar, `fullSizeContentView`, traffic-light controls preserved as real `NSWindow` chrome.
