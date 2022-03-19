// AppCommands.swift
// Maria2

import SwiftUI

struct AppCommands: Commands {
    @Binding var presentedSheet: AppState.Sheet?
    let openFile: () -> Void

    var body: some Commands {
        CommandGroup(replacing: .help) {}
        CommandGroup(replacing: .newItem) {
            Button("New URL download") {
                presentedSheet = .newDownload
            }
            .keyboardShortcut("N", modifiers: [.command])
            Button("Open URLs file") {
                openFile()
            }
            .keyboardShortcut("O")
        }
    }
}
