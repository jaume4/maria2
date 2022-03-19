// AddURLView.swift
// Maria2

import SwiftUI

struct AddURLView: View {
    @EnvironmentObject var appState: AppState
    @State var urlString = ""

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack {
                Text("New download:")
                    .fixedSize(horizontal: true, vertical: true)
                    .font(.body)
                Spacer()
            }

            HStack {
                Text("URL")
                TextField("URL", text: $urlString)
            }
            .frame(maxWidth: 400)

            HStack {
                Button {
                    appState.presentedSheet = nil
                } label: {
                    Text("Cancel")
                        .frame(minWidth: 100)
                }
                .keyboardShortcut(.cancelAction)

                Button {
                    appState.addNewDownload(string: urlString)
                    appState.presentedSheet = nil
                } label: {
                    Text("Add")
                        .frame(minWidth: 100)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(URL(string: urlString) == nil)
            }
            .padding(.top, 6)
        }
        .padding()
    }
}

struct AddURLView_Previews: PreviewProvider {
    static let state: AppState = {
        let state = AppState()
        state.downloads.append(contentsOf: DownloadView_Previews.downloads)
        return state
    }()

    static var previews: some View {
        AddURLView()
            .environmentObject(state)
    }
}
