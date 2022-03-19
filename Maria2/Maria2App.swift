// Maria2App.swift
// Maria2

import SwiftUI

@main
struct Maria2App: App {
    @StateObject private var appState: AppState

    init() {
        _appState = StateObject(wrappedValue: AppState())
    }

    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(appState)
                .navigationTitle("Maria2")
                .toolbar { toolbar }
                .frame(minWidth: 400, minHeight: 400)
                .onDrop(of: [.fileURL, .plainText], delegate: appState.dropDelegate)
        }

        .commands {
            AppCommands(presentedSheet: $appState.presentedSheet,
                        openFile: { [unowned appState] in
                            appState.openFile()
                        })
        }
    }

    var toolbar: some View {
        ControlGroup {
//            Button(action: {}, label: { Image(systemName: Bool.random() ? "play.fill" : "pause.fill") })
            Button {
                appState.openFile()
            } label: {
                Image(systemName: "doc.plaintext.fill")
            }
            .help("New downloads from URL file")
            .keyboardShortcut("o", modifiers: [.command])

            Button {
                appState.presentedSheet = .newDownload
            } label: {
                Image(systemName: "link")
            }
            .help("New download from URL")
            .keyboardShortcut("p")
        }
    }
}
