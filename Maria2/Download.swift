// Download.swift
// Maria2

import Combine
import Foundation

@MainActor
final class Download: ObservableObject {
    @Published var renamed: String? = nil
    @Published var channels: Int = 0
    @Published var progress = Progress()
    @Published var url: URL
    @Published var status: Status = .notStarted

    var task: Task<Void, Never>?

    init(url: URL) {
        self.url = url
        progress.kind = .file
        progress.fileOperationKind = .downloading
    }

    func download() {
        task?.cancel()

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
            return "Error"
        case .finished:
            return "Finished"
        }
    }

    private func generateDownloadTask() -> Task<Void, Never>? {
        Task {
            for await ariaUpdate in DownloadTask.launch(url: url) {
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
                    case let .finished(status):
                        self.status = .finished
                        self.progress.completedUnitCount = self.progress.totalUnitCount
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
