// DownloadView.swift
// Maria2

import SwiftUI

struct DownloadView: View {
    @ObservedObject var download: Download

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(download.url.absoluteString)
                    .font(.headline)
                    .lineLimit(1)
                Spacer(minLength: 20)
            }

            HStack {
                ProgressView(value: download.progress.fractionCompleted)
                    .progressViewStyle(LinearProgressViewStyle(tint: color(for: download.status)))
                    .help("Downloading: \(Int(download.progress.fractionCompleted * 100))% complete")
                Button {
                    download.tappedPlayPauseButton()
                } label: {
                    image(for: download.status)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Text(download.statusText())
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    func image(for status: Download.Status) -> Image {
        switch status {
        case .notStarted, .downloading:
            return Image(systemName: "stop.circle.fill")
        case .cancelled, .error:
            return Image(systemName: "arrow.clockwise.circle.fill")
        case .finished:
            return Image(systemName: "magnifyingglass.circle.fill")
        }
    }

    func color(for status: Download.Status) -> Color {
        switch status {
        case .notStarted, .downloading:
            return .accentColor
        case .cancelled, .error:
            return .gray
        case .finished:
            return .green
        }
    }
}

struct DownloadView_Previews: PreviewProvider {
    static func baseDownload() -> Download {
        let download = Download(url: URL(string: "http://mac-mini.local:8000/video.zip")!, destination: URL(string: "~")!)
        download.progress.totalUnitCount = 100_000
        download.progress.completedUnitCount = 3000
        download.progress.throughput = 20_000
        download.progress.estimatedTimeRemaining = 20
        download.status = .downloading
        download.channels = .random(in: 9 ... 11)

        return download
    }

    static let notStarted: Download = {
        let download = baseDownload()
        download.status = .notStarted

        return download
    }()

    static let cancelled: Download = {
        let download = baseDownload()
        download.status = .cancelled

        return download
    }()

    static let finished: Download = {
        let download = baseDownload()
        download.status = .finished
        download.progress.totalUnitCount = 100_000
        download.progress.completedUnitCount = 100_000

        return download
    }()

    static let downloads = [
        notStarted,
        baseDownload(),
        cancelled,
        finished,
    ]

    static var previews: some View {
        VStack {
            ForEach(downloads) {
                DownloadView(download: $0)
                Divider()
            }
        }.padding()
    }
}
