// AppState.swift
// Maria2

import SwiftUI

@MainActor
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
            self.parseFileURLsAndGenerateDownloads(from: url)
        } newDownloadFromURL: { [unowned self] url in
            self.addNewDownload(url: url)
        }

        if destinationFolder == nil {
            destinationFolder = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
        }
    }

    func addNewDownload(string: String) {
        guard let url = URL(string: string) else {
            return
        }

        addNewDownload(url: url)
    }

    func addNewDownload(url: URL) {
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

        parseFileURLsAndGenerateDownloads(from: url)
    }

    private func parseFileURLsAndGenerateDownloads(from file: URL) {
        Task.detached(priority: .userInitiated) {
            let urls = await URLParser.parseURLs(from: file)

            await MainActor.run {
                for url in urls {
                    self.addNewDownload(url: url)
                }
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
