// MainWindow.swift
// Maria2

import SwiftUI

struct MainWindow: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.downloads.isEmpty {
                downloadView
            } else {
                emptyView
            }
        }
        .sheet(item: $appState.presentedSheet, content: sheetView(for:))
    }

    var downloadView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if !appState.downloads.isEmpty {
                    ForEach(appState.downloads) {
                        DownloadView(download: $0)
                        Divider()
                    }
                } else {}
            }
            .padding()
        }
    }

    var emptyView: some View {
        Text("Add a download to start")
            .frame(alignment: .center)
            .padding()
    }

    private func sheetView(for sheet: AppState.Sheet) -> some View {
        Group {
            switch sheet {
            case .newDownload:
                AddURLView()
            case .preferences:
                AddURLView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
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
