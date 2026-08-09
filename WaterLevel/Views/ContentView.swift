//
//  ContentView.swift
//  WaterLevel
//

import SwiftUI

struct ContentView: View {
    @StateObject private var state = AppState()
    private var theme: Theme { state.theme }

    @State private var showAnnualSummary = false

    var body: some View {
        VStack(spacing: 0) {
            header
            DashboardView(theme: theme)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 36)
                .padding(.bottom, 20)
        }
        .environmentObject(state)
        .background(theme.background)
        .foregroundStyle(theme.text)
        .frame(minWidth: 860, minHeight: 640)
        .background(WindowConfigurator())
        .preferredColorScheme(state.isDark ? .dark : .light)
        .task {
            await state.fetchData()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3600))
                guard !Task.isCancelled else { break }
                await state.fetchData()
            }
        }
    }

    private var syncLabel: String {
        guard let date = state.lastUpdated else { return "LIVE" }
        let secs = Int(-date.timeIntervalSinceNow)
        if secs < 60   { return "LIVE · SYNCED JUST NOW" }
        if secs < 3600 { return "LIVE · SYNCED \(secs / 60)M AGO" }
        return "LIVE · SYNCED \(secs / 3600)H AGO"
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(state.selectedLake.name) WATER LEVEL MONITOR")
                    .font(AppFont.heading(16))
                HStack(spacing: 8) {
                    Text(state.selectedLake.location)
                        .font(AppFont.body(10.5, weight: .semibold))
                        .tracking(0.4)
                        .foregroundStyle(theme.textMuted(0.45))
                    Text("·")
                        .foregroundStyle(theme.textMuted(0.25))
                    HStack(spacing: 5) {
                        if state.isLoadingData {
                            PulsingDot(color: theme.textMuted(0.5))
                        } else {
                            Rectangle()
                                .fill(theme.accent)
                                .frame(width: 5, height: 5)
                        }
                        Text(state.isLoadingData ? "FETCHING DATA…" : syncLabel)
                            .font(AppFont.body(10.5, weight: .bold))
                            .foregroundStyle(state.isLoadingData ? theme.textMuted(0.4) : theme.accent)
                    }
                }
            }

            Spacer()

            Menu {
                ForEach(Lake.all) { lake in
                    Button {
                        state.selectLake(lake)
                    } label: {
                        if lake == state.selectedLake {
                            Label(lake.name, systemImage: "checkmark")
                        } else {
                            Text(lake.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("LAKE")
                        .font(AppFont.body(11, weight: .semibold))
                        .tracking(0.3)
                        .foregroundStyle(theme.textMuted(0.5))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(theme.textMuted(0.35))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 1.5))
            }
            .menuStyle(.borderlessButton)
            .fixedSize()

            Button {
                showAnnualSummary.toggle()
            } label: {
                Text("ANNUAL SUMMARY")
                    .font(AppFont.body(11, weight: .semibold))
                    .tracking(0.3)
                    .foregroundStyle(showAnnualSummary ? theme.text : theme.textMuted(0.5))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(Rectangle().strokeBorder(theme.divider, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showAnnualSummary, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("ANNUAL SUMMARY")
                        .font(AppFont.body(13, weight: .heavy))
                        .tracking(0.2)
                    HistoricalTableView(theme: theme)
                }
                .padding(24)
                .frame(minWidth: 520)
                .background(theme.background)
                .foregroundStyle(theme.text)
                .environmentObject(state)
            }

            FlatSegmentedControl(
                options: [false, true],
                label: { $0 ? "DARK" : "LIGHT" },
                selection: $state.isDark,
                theme: theme,
                fontSize: 11
            )
        }
        .padding(.top, 30)
        .padding(.bottom, 16)
        .overlay(alignment: .bottom) {
            ZStack {
                Rectangle().fill(theme.divider).frame(height: 1)
                if state.isLoadingData {
                    LoadingBar(color: theme.accent)
                }
            }
        }
        .padding(.horizontal, 36)
    }
}

// Animated shimmer bar — sweeps left-to-right while loading
private struct LoadingBar: View {
    let color: Color
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let barW = geo.size.width * 0.4
            LinearGradient(
                colors: [.clear, color.opacity(0.5), color, color.opacity(0.5), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: barW, height: 2)
            .offset(x: phase * (geo.size.width + barW) - barW)
        }
        .frame(height: 2)
        .clipped()
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// Pulsing dot for the loading state indicator
private struct PulsingDot: View {
    let color: Color
    @State private var opacity: Double = 1

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 5, height: 5)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                    opacity = 0.15
                }
            }
    }
}

#Preview {
    ContentView()
}
