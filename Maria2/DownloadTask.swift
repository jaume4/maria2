// DownloadTask.swift
// Maria2

import Foundation

enum DownloadTask {
    static func launch(url: URL, destination: URL) -> AsyncStream<Aria2Progress> {
        AsyncStream { continuation in

            let aria2Process = Process()

            Task {
                let aria2URL = Bundle.main.url(forAuxiliaryExecutable: "aria2c")

                aria2Process.qualityOfService = .userInitiated
                aria2Process.executableURL = aria2URL
                aria2Process.arguments = [
                    "--max-connection-per-server=16",
                    "--split=16",
                    "--summary-interval=1",
                    "--file-allocation=none",
                    "--stop-with-process=\(ProcessInfo.processInfo.processIdentifier)",
                    "--dir=\(destination.terminalPath)",
                    "--show-console-readout=false",
                    "--human-readable=false",
                    url.absoluteString,
                ]

                let stdOutPipe = Pipe()
                aria2Process.standardOutput = stdOutPipe
                let stdErrPipe = Pipe()
                aria2Process.standardError = stdErrPipe

                let updateBlock: ((FileHandle) -> Void) = { fileHandle in
                    guard let update = parse(data: fileHandle.availableData) else {
                        return
                    }

                    continuation.yield(update)
                }

                stdOutPipe.fileHandleForReading.readabilityHandler = updateBlock
                stdErrPipe.fileHandleForReading.readabilityHandler = updateBlock

                try aria2Process.run()

                aria2Process.waitUntilExit()

                let terminationStatus = Aria2CTerminationStatus(exitStatus: aria2Process.terminationStatus)
                continuation.yield(.finished(terminationStatus))

                continuation.finish()
            }

            continuation.onTermination = { @Sendable termination in
                switch termination {
                case .cancelled:
                    aria2Process.terminate()
                case .finished:
                    break
                @unknown default:
                    break
                }
            }
        }
    }

    static func parse(data: Data) -> Aria2Progress? {
        let string = String(decoding: data, as: UTF8.self)

        guard !string.isEmpty else {
            return nil
        }

        do {
            let result = try Aria2Progress.OutputParse.parse(string[...])
            return result
        } catch {
            return nil
        }
    }
}
