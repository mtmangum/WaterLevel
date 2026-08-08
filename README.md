# Travis Level

A native macOS app for monitoring real-time and historical water levels for Lake Travis, TX.

## Features

- **Dashboard** — current lake level, inflow, outflow, and vs-historical-average stats at a glance
- **12-month chart** — trailing water level vs. 30-year average, with faint daily rainfall bars
- **Interactive crosshair** — hover over the chart for a vertical tracking line and level tooltip
- **Time range selector** — 1M / 1Y / 5Y / ALL scopes the dashboard chart
- **Historical view** — multi-year level comparison chart (2024–2026 + 30-yr avg) and data table
- **Dark / Light mode** — toggled from the sidebar footer; default is dark

## Design

Modernist flat system: mono red-on-white/black, SF Pro Heavy/Bold (Archivo target), zero corner radius, 2px rule dividers throughout. Defined in `Theme.swift`.

## Data

Currently uses static placeholder data. Intended data sources: USGS or LCRA lake level API.

| Constant | Value |
|---|---|
| Full pool | 681 ft MSL |
| Low-level threshold | 605 ft MSL |
| Displayed current level | 638.4 ft (placeholder) |

## Requirements

- macOS 13 Ventura or later
- Xcode 15 or later

## Project structure

```
WaterLevel/
├── AppState.swift          — shared observable state (tab, range, theme)
├── Theme.swift             — design tokens, AppFont, Spacing
├── ContentView.swift       — root layout: sidebar + header + scroll area
├── SidebarView.swift       — nav list, brand block, Light/Dark toggle
├── DashboardView.swift     — stat grid + chart card
├── StatGridView.swift      — 4-column stat row with 2px dividers
├── DashboardChartCard.swift— trailing chart with hover crosshair
├── HistoricalView.swift    — multi-year chart + data table
├── HistoricalChartCard.swift
├── HistoricalTableView.swift
├── ChartGeometry.swift     — bezier path helpers (1000×320 SVG viewBox)
├── FlatSegmentedControl.swift
├── Tag.swift               — square chip (accent / neutral / outline)
└── WindowConfigurator.swift— NSWindow: transparent titlebar, fullSizeContentView
```

## Status

Static placeholder data — wire up to a live API before shipping.
