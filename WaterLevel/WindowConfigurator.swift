//
//  WindowConfigurator.swift
//  WaterLevel
//
//  Makes the sidebar sit flush with the title bar so the native traffic-light
//  controls read as part of the app's brand block, per the handoff (draw no
//  custom traffic lights — use real NSWindow chrome).
//

import SwiftUI

struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
