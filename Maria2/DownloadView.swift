// DownloadView.swift
// Maria2

import SwiftUI

struct DownloadView: View {
    let url: URL
    let progress: Double
    let text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(url.absoluteString)
                .font(.headline)

            HStack {
                ProgressView(value: progress)
                    .help("Downloading: \(Int(progress * 100))% complete")
                Button {
                    print("tapped")
                } label: {
                    Image(systemName: "pause.circle.fill")
                }
                .buttonStyle(PlainButtonStyle())
            }

            if text.isEmpty {
                ProgressView()
            } else {
                Text(text
                    .replacingOccurrences(of: " — ", with: "\n"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadView(url: URL(string: "http://mac-mini.local:8000/video.zip")!,
                     progress: 0.3,
                     text: "146,3 MB of 16,37 GB (10,6 MB/sec) — About 25 minutes, 32 seconds remaining")
    }
}
