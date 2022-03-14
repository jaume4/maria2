// MainWindow.swift
// Maria2

import SwiftUI

struct MainWindow: View {
    @EnvironmentObject var appState: AppState
    @State var urlString = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TextField("URL", text: $urlString)

                Button("Download") {
                    appState.newDownload(string: urlString)
                }

                ForEach(appState.downloads, id: \.url) {
                    DownloadView(url: $0.url, progress: $0.progress.fractionCompleted, text: $0.progress.localizedAdditionalDescription)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow()
    }
}
