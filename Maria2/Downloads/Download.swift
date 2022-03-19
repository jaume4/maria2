// Download.swift
// Maria2

import AppKit
import Foundation

@MainActor
final class Download: ObservableObject, Identifiable {
    @Published var renamed: String? = nil
    @Published var channels: Int = 0
    @Published var progress = Progress()
    @Published var url: URL
    @Published var status: Status = .notStarted
    @Published var destinationFolder: URL
    @Published var aria2Status: Aria2CTerminationStatus?

    var task: Task<Void, Never>?

    init(url: URL, destination: URL) {
        self.url = url
        destinationFolder = destination
        progress.kind = .file
        progress.fileOperationKind = .downloading
    }

    func download() {
        task?.cancel()
        aria2Status = nil

        generateDownloadTask()
    }

    func cancel() {
        task?.cancel()
        task = nil

        status = .cancelled
    }

    func tappedPlayPauseButton() {
        switch status {
        case .notStarted, .downloading:
            cancel()
        case .error:
            download()
        case .cancelled:
            download()
        case .finished:
            let url: URL
            if let renamed = renamed {
                url = destinationFolder.appendingPathComponent(renamed).fileURL
            } else {
                url = destinationFolder.appendingPathComponent(self.url.lastPathComponent).fileURL
            }
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }

    func remove() {}

    func statusText() -> String {
        switch status {
        case .notStarted:
            return "Waiting"
        case .downloading:
            return progress.localizedAdditionalDescription
                .replacingOccurrences(of: " — ", with: "\n")
        case .cancelled:
            return "Cancelled"
        case .error:
            return aria2Status?.description ?? "Unknown error"
        case .finished:
            return "Finished"
        }
    }

    private func generateDownloadTask() {
        task = Task.detached { [weak self, url, destinationFolder] in
            for await ariaUpdate in DownloadTask.launch(url: url, destination: destinationFolder) {
                guard let self = self else {
                    return
                }

                await MainActor.run {
                    switch ariaUpdate {
                    case let .update(progressReport):
                        self.status = .downloading
                        self.channels = progressReport.channels

                        self.progress.throughput = progressReport.speed
                        self.progress.estimatedTimeRemaining = Double(progressReport.eta)
                        self.progress.totalUnitCount = Int64(progressReport.total)
                        self.progress.completedUnitCount = Int64(progressReport.downloaded)

                    case let .renamed(newName):
                        self.renamed = newName
                    case let .finished(aria2Status):
                        if aria2Status == .finished {
                            self.status = .finished
                            self.progress.completedUnitCount = self.progress.totalUnitCount
                        } else {
                            self.status = .error
                            self.aria2Status = aria2Status
                        }
                    }
                }
            }
        }
    }
}

extension Download {
    enum Status {
        case notStarted, downloading, error, cancelled, finished
    }
}
