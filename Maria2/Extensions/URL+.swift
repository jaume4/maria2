// URL+.swift
// Maria2

import Foundation

extension URL {
    var fileURL: URL {
        if scheme == nil {
            return URL(string: "file://" + absoluteString)!
        } else {
            return self
        }
    }

    var terminalPath: String {
        let path = absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .replacingOccurrences(of: "%20", with: " ")

        if path.last == "/" {
            return String(path.dropLast())
        } else {
            return path
        }
    }
}
