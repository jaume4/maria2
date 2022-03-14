// DownloadManager.swift
// Maria2

import Combine
import Foundation

@MainActor
final class DownloadManager: ObservableObject {
    @Published var renamed: String? = nil
    @Published var channels: Int = 0
    @Published var progress = Progress()
    @Published var url: URL
    @Published var downloading = false

    var task: Task<Void, Never>?

    init(url: URL) {
        self.url = url
        progress.kind = .file
        progress.fileOperationKind = .downloading
    }

    func download() {
        task?.cancel()

        if let task = generateDownloadTask() {
            downloading = true
            self.task = task

            Task.detached(priority: .userInitiated) {
                await task.value
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil

        downloading = false
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
                        downloading = false
                    }
                }
            }
        }
    }
}
