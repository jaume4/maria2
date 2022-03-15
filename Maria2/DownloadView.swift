// DownloadView.swift
// Maria2

import SwiftUI

struct DownloadView: View {
    @ObservedObject var download: Download

    var body: some View {
        VStack(alignment: .leading) {
            Text(download.url.absoluteString)
                .font(.headline)

            HStack {
                ProgressView(value: download.progress.fractionCompleted)
                    .progressViewStyle(LinearProgressViewStyle(tint: color(for: download.status)))
                    .help("Downloading: \(Int(download.progress.fractionCompleted * 100))% complete")
                Button {
                    print("tapped")
                } label: {
                    image(for: download.status)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Text(download.statusText())
                .font(.subheadline)
                .foregroundColor(.secondary)
        }

        .padding()
    }

    func image(for status: Download.Status) -> Image {
        switch status {
        case .notStarted, .downloading:
            return Image(systemName: "pause.circle.fill")
        case .cancelled, .error:
            return Image(systemName: "restart.circle.fill")
        case .finished:
            return Image(systemName: "xmark.circle.fill")
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

// struct DownloadView_Previews: PreviewProvider {
//    static var previews: some View {
//        DownloadView(url: URL(string: "http://mac-mini.local:8000/video.zip")!,
//                     progress: 0.3,
//                     text: "146,3 MB of 16,37 GB (10,6 MB/sec) — About 25 minutes, 32 seconds remaining")
//    }
// }
