// AppState.swift
// Maria2

import Foundation
import SwiftUI

final class AppState: ObservableObject {
    @Published var downloads: [Download] = []

    @MainActor
    func newDownload(string: String) {
        guard let url = URL(string: string) else {
            return
        }

        let manager = Download(url: url)
        manager.url = url

        manager.download()
        downloads.append(manager)
    }
}
