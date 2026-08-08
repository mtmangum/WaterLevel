# Changelog

All notable changes to Travis Level are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Added
- **Hover crosshair on dashboard chart** — vertical tracking line (accent red, 45% opacity) follows the mouse; a dot snaps to the bezier curve; a square tooltip shows the nearest date label and interpolated water level in ft. Tooltip flips left when near the right edge.
- **Range buttons wired to chart** — 1M / 1Y / 5Y / ALL each produce distinct curve data, axis labels, and chart title. Previously the selection was visual-only.

### Fixed
- Sidebar nav items no longer show SF Symbol icons — design spec calls for flush-left text only.
- "Historical" nav label corrected to "Historical Trends".
- Range segmented control (1M / 1Y / 5Y / ALL) now only renders on the Dashboard tab; Historical Trends has no time-range control.
- `FlatSegmentedControl` border no longer renders as an oversized box — added `.fixedSize(horizontal: false, vertical: true)` to prevent internal `Rectangle` dividers from accepting the parent's full offered height.
- Header `HStack` alignment changed from `.lastTextBaseline` to `.center` so the segmented control positions correctly relative to the title block.
- Historical chart 605 ft gridline now renders as a solid accent-red line (low-level threshold), matching the dashboard chart. Was incorrectly muted and dashed.

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
