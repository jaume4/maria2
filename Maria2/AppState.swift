// AppState.swift
// Maria2

import SwiftUI

final class AppState: ObservableObject {
    @Published var downloads: [Download] = []
    @Published var presentedSheet: Sheet?
    @AppStorage var destinationFolder: URL!

    init() {
        _destinationFolder = AppStorage("destinationFolder")
        if destinationFolder == nil {
            destinationFolder = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
        }
    }

    func newDownload(string: String) {
        guard let url = URL(string: string) else {
            return
        }

        newDownload(url: url)
    }

    func newDownload(url: URL) {
        let manager = Download(url: url, destination: destinationFolder)
        manager.url = url

        manager.download()
        downloads.append(manager)
    }

    func openFile() {
        let openPanel = NSOpenPanel()
        openPanel.message = "Select a file with URL separated by newlines"

        openPanel.allowedContentTypes = [.plainText]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        guard openPanel.runModal() == .OK,
              let url = openPanel.url
        else {
            return
        }

        URLParser.parseURLs(from: url)
            .forEach(newDownload(url:))
    }
}

extension AppState {
    enum Sheet: Identifiable {
        var id: Int {
            hashValue
        }

        case newDownload
        case preferences
    }
}
