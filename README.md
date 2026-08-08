# WaterLevel

A native macOS app for monitoring real-time and historical water levels for Lake Travis, Austin TX.

## Features

- **Dashboard** — current lake level, inflow, outflow, and vs-historical-average stats
- **5-year overlay chart** — 2022–2026 lines on a shared Jan–Dec axis; current year (2026) in blue with a live endpoint dot
- **Year toggles** — single-tap hides/shows a year; double-tap isolates it
- **Interactive crosshair** — hover shows interpolated water level (ft) for every visible year
- **Annual Summary popover** — header button opens a historical min/max/avg table without leaving the dashboard
- **Dark / Light mode** — toggled from the header; default is dark

## Design

Flat modernist system: SF Pro Heavy/Bold, zero corner radius, 2px rule dividers, neutral ramp + `#2B82D4` water blue + `#EC3013` accent red. Tokens defined in `Theme.swift`.

## Data

Currently uses static placeholder data. Intended live source: LCRA Hydromet API.

| Constant | Value |
|---|---|
| Full pool | 681 ft MSL |
| Low-level threshold | 605 ft MSL |
| Current level (placeholder) | 638.4 ft |

## Requirements

- macOS 13 Ventura or later
- Xcode 15 or later

## Project structure

```
WaterLevel/
├── AppState.swift
├── WaterLevelApp.swift
├── Assets.xcassets/
├── Components/
│   ├── FlatSegmentedControl.swift
│   └── Tag.swift
├── Support/
│   ├── ChartGeometry.swift     — bezier path helpers (1000×255 SVG viewBox)
│   ├── Theme.swift             — design tokens, AppFont, Spacing
│   └── WindowConfigurator.swift
└── Views/
    ├── ContentView.swift       — root layout: header + dashboard
    ├── SidebarView.swift
    ├── Dashboard/
    │   ├── DashboardView.swift         — proportional layout (1/4 stats, 3/4 chart)
    │   ├── StatGridView.swift          — 5-column stat row
    │   └── DashboardChartCard.swift    — 5-year overlay chart with crosshair
    └── Historical/
        ├── HistoricalView.swift
        ├── HistoricalChartCard.swift
        └── HistoricalTableView.swift
```
