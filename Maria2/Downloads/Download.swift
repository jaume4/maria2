// Download.swift
// Maria2

import AppKit
import Foundation

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

        if let task = generateDownloadTask() {
            status = .downloading
            self.task = task

            Task.detached(priority: .userInitiated) {
                await task.value
            }
        }
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
        case .notStarted,
             .downloading where progress.localizedAdditionalDescription.isEmpty:
            return "Starting"
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

    private func generateDownloadTask() -> Task<Void, Never>? {
        Task {
            for await ariaUpdate in DownloadTask.launch(url: url, destination: destinationFolder) {
                await MainActor.run {
                    switch ariaUpdate {
                    case let .update(progressReport):
                        channels = progressReport.channels

                        progress.throughput = progressReport.speed
                        progress.estimatedTimeRemaining = Double(progressReport.eta)
                        progress.totalUnitCount = Int64(progressReport.total)
                        progress.completedUnitCount = Int64(progressReport.downloaded)

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
