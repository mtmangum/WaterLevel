# Changelog

All notable changes to WaterLevel are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

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
