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

                ForEach(appState.downloads) {
                    DownloadView(download: $0)
                    Divider()
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @MainActor
    static let state: AppState = {
        let state = AppState()
        state.downloads.append(contentsOf: DownloadView_Previews.downloads)
        return state
    }()

    static var previews: some View {
        MainWindow()
            .environmentObject(state)
    }
}
