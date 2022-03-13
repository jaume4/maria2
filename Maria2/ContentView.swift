// ContentView.swift
// Maria2

import SwiftUI

struct ContentView: View {
    @StateObject var manager = DownloadManager()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                TextField("URL", text: $manager.urlString)

                Button(manager.downloading ? "Cancel" : "Download") {
                    manager.downloading ? manager.cancel() : manager.download()
                }
                .disabled(manager.url == nil)

                ProgressView(value: manager.progress.fractionCompleted)

                    .help("Downloading: \(Int(manager.progress.fractionCompleted * 100))% complete")

                Text(manager.progress.localizedAdditionalDescription
                    .replacingOccurrences(of: " — ", with: "\n"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
