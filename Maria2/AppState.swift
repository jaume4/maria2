// AppState.swift
// Maria2

import SwiftUI

final class AppState: ObservableObject {
    @Published var downloads: [Download] = []
    @Published var presentedSheet: Sheet?
    @Published var dropStatus: FileDropDelegate.Status = .none
    @AppStorage var destinationFolder: URL!
    var dropDelegate: FileDropDelegate!

    init() {
        _destinationFolder = AppStorage("destinationFolder")

        dropDelegate = FileDropDelegate { [unowned self] status in
            self.dropStatus = status
        } parseFileDownloads: { [unowned self] url in
            self.parseFileDownloads(from: url)
        } newDownloadFromURL: { [unowned self] url in
            self.newDownload(url: url)
        }

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
        openPanel.message = "Select a file with URLs separated by newlines"

        openPanel.allowedContentTypes = [.plainText]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        guard openPanel.runModal() == .OK,
              let url = openPanel.url
        else {
            return
        }

        parseFileDownloads(from: url)
    }

    func parseFileDownloads(from file: URL) {
        Task.detached(priority: .userInitiated) {
            let urls = await URLParser.parseURLs(from: file)

            await MainActor.run {
                urls.forEach(self.newDownload(url:))
            }
        }
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
