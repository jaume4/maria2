// FileDropDelegate.swift
// Maria2

import SwiftUI
import UniformTypeIdentifiers

struct FileDropDelegate: DropDelegate {
    enum Status {
        case entered, done, none
    }

    let updateAction: (Status) -> Void
    let parseFileDownloads: (URL) -> Void
    let newDownloadFromURL: (URL) -> Void

    init(updateAction: @escaping ((Status) -> Void),
         parseFileDownloads: @escaping (URL) -> Void,
         newDownloadFromURL: @escaping (URL) -> Void)
    {
        self.updateAction = updateAction
        self.parseFileDownloads = parseFileDownloads
        self.newDownloadFromURL = newDownloadFromURL
    }

    func performDrop(info: DropInfo) -> Bool {
        if info.hasItemsConforming(to: [.fileURL]) {
            let urlProviders = info.itemProviders(for: [.fileURL])

            urlProviders.forEach { provider in
                Task.detached {
                    let urlData = try await provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil)

                    var isDirectory: ObjCBool = false

                    guard let data = urlData as? Data,
                          let url = URL(string: String(decoding: data, as: UTF8.self)),
                          FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
                          !isDirectory.boolValue
                    else {
                        print("Dropped a folder, ignoring")
                        return
                    }

                    parseFileDownloads(url)
                }
            }
        } else if info.hasItemsConforming(to: [.url]) {
            let urlProviders = info.itemProviders(for: [.url])

            urlProviders.forEach { provider in
                Task.detached {
                    guard let data = try await provider.loadItem(forTypeIdentifier: UTType.url.identifier) as? Data,
                          let url = URL(string: String(decoding: data, as: UTF8.self))
                    else {
                        return
                    }

                    await MainActor.run {
                        newDownloadFromURL(url)
                    }
                }
            }

        } else {
            return false
        }

        return true
    }

    func dropEntered(info: DropInfo) {
        updateAction(.entered)
    }

    func dropExited(info: DropInfo) {
        updateAction(.none)
    }
}
