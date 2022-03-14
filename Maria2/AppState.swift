// AppState.swift
// Maria2

import Foundation
import SwiftUI

final class AppState: ObservableObject {
    @Published var downloads: [DownloadManager] = []

    @MainActor
    func newDownload(string: String) {
        guard let url = URL(string: string) else {
            return
        }

        let manager = DownloadManager(url: url)
        manager.url = url

        manager.download()
        downloads.append(manager)
    }
}
