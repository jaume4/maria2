// Maria2App.swift
// Maria2

import SwiftUI

@main
struct Maria2App: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(appState)
                .navigationTitle("Maria2")
                .toolbar {
                    Button(action: {}, label: { Image(systemName: Bool.random() ? "play.fill" : "pause.fill") })
                    Button(action: {}, label: { Image(systemName: "plus") })
                }
        }
    }
}
