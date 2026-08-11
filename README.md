# LakeLevel

A native macOS app for monitoring real-time and historical water levels for all six LCRA Highland Lakes in Texas. A React/Vite web port is also live at **[highlandlakelevels.org](https://highlandlakelevels.org)**.

![LakeLevel dark mode](screenshots/app-dark.png)

## Features

- **All six Highland Lakes** — switch between Lake Buchanan, Inks, LBJ, Marble Falls, Travis, and Austin via the LAKE ▾ picker in the header
- **Dashboard** — current lake level, inflow, outflow, and vs-30-yr-average stats; updates automatically every hour
- **5-year overlay chart** — 2022–2026 lines on a shared Jan–Dec axis; current year in blue with a live endpoint dot
- **Year toggles** — single-tap hides/shows a year; double-tap isolates it
- **Interactive crosshair** — hover shows interpolated water level (ft) for every visible year
- **Drag to zoom** — drag across the chart to zoom into a date range; RESET to restore full view
- **Annual Summary popover** — header button opens a live min/max/avg/year-end table for the selected lake
- **Dark / Light mode** — toggled from the header; default is dark
- **Disk cache** — chart renders instantly from cache on relaunch; network refresh runs in the background

## Design

Flat modernist system: SF Pro Heavy/Bold, zero corner radius, 1 px rule dividers, neutral ramp + `#2B82D4` water blue + `#EC3013` accent red. Tokens defined in `Theme.swift`.

## Data

Live daily readings from [waterdatafortexas.org](https://waterdatafortexas.org/) (LCRA). Both the trailing-year CSV and the full historical record (since 1940) are fetched on launch and cached to `~/Library/Application Support/WaterLevel/`. Data refreshes automatically every hour while the app is running.

| Lake | Full Pool |
|---|---|
| Lake Buchanan | 1020.5 ft MSL |
| Lake Inks | 888.25 ft MSL |
| Lake LBJ | 824.0 ft MSL |
| Lake Marble Falls | 738.5 ft MSL |
| Lake Travis | 681.0 ft MSL |
| Lake Austin | 492.0 ft MSL |

## Requirements

- macOS 26 or later
- Xcode 26 or later

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
│   ├── Lake.swift              — Highland Lake definitions + per-lake coordinate math
│   ├── LakeDataService.swift   — CSV fetch, parse, and disk cache
│   ├── Theme.swift             — design tokens, AppFont, Spacing
│   └── WindowConfigurator.swift
└── Views/
    ├── ContentView.swift       — root layout: header + lake picker + dashboard
    └── Dashboard/
        ├── DashboardView.swift         — proportional layout (1/4 stats, 3/4 chart)
        ├── StatGridView.swift          — 4-column stat row
        ├── DashboardChartCard.swift    — 5-year overlay chart with crosshair + zoom
        └── Historical/
            └── HistoricalTableView.swift — live annual summary table
```

## Web app

A React/Vite/TypeScript port of the same dashboard lives in `web/`, deployed to Netlify at [highlandlakelevels.org](https://highlandlakelevels.org). It mirrors the native app's feature set — lake picker, stat grid, 5-year overlay chart with crosshair/zoom/legend toggles, Annual Summary table — plus a mobile-responsive layout (stacking header/stat grid, touch-enabled chart, full-screen summary sheet under 640px) and shareable `?lake=` deep links.

**Local development:**
```
cd web
npm install
npm run dev
```

**Data fetching:** a Netlify serverless function (`web/netlify/functions/lake-csv.js`) proxies CSV requests to waterdatafortexas.org to avoid CORS issues; the frontend calls it via the `/api/lake-csv` redirect defined in `web/netlify.toml`.

**Deployment:** the Netlify site is linked to this GitHub repo (base directory `web`) — every push to `main` auto-builds and deploys. Manual deploys (`netlify deploy --prod` from `web/`) also work if needed.

```
web/
├── index.html
├── netlify.toml               — build config + /api/* redirect
├── netlify/functions/
│   └── lake-csv.js            — CORS proxy to waterdatafortexas.org
├── public/
│   └── favicon.svg
└── src/
    ├── App.tsx
    ├── theme.ts                — COLORS + makeTheme(isDark)
    ├── components/
    │   ├── Header.tsx
    │   ├── StatGrid.tsx
    │   ├── DashboardChart.tsx
    │   └── AnnualSummary.tsx
    ├── hooks/
    │   └── useAppState.ts      — lake selection, data fetching, derived stats
    └── data/
        ├── lakes.ts            — Lake definitions + coordinate helpers
        └── lakeDataService.ts  — CSV fetch + parse
```
