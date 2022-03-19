// MainWindow.swift
// Maria2

import SwiftUI

struct MainWindow: View {
    @EnvironmentObject var appState: AppState
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            Group {
                if !appState.downloads.isEmpty {
                    downloadView
                } else {
                    emptyView
                }
            }
            if appState.dropStatus == .entered {
                animateDropFileView
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
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "arrow.down.doc.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .font(.largeTitle)
            Text("Drag a URL or file to start new downloads")
        }
    }

    var animateDropFileView: some View {
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 8.00, lineCap: .round, lineJoin: .round,
                                       miterLimit: 24.00, dash: [25.0, 25.0, 0.0, 25.0], dashPhase: phase))
            .foregroundColor(Color.accentColor)
            .padding(5)
            .transition(.opacity.animation(.easeInOut))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    phase -= 75
                }
            }
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
