// AppState.swift
// Maria2

import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var downloads: [Download] = []
    @AppStorage var destinationFolder: URL!

    init() {
        _destinationFolder = AppStorage("destinationFolder")
        if destinationFolder == nil {
            destinationFolder = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
        }
    }

    @MainActor
    func newDownload(string: String) {
        guard let url = URL(string: string) else {
            return
        }

        let manager = Download(url: url, destination: destinationFolder)
        manager.url = url

        manager.download()
        downloads.append(manager)
    }
}
