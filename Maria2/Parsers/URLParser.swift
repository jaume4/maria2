// URLParser.swift
// Maria2

import Foundation
import Parsing

enum URLParser {
    static func parseURLs(from url: URL) async -> [URL] {
        await Task(priority: .userInitiated) {
            do {
                let data = try Data(contentsOf: url)
                return try FileParser.parse(String(decoding: data, as: UTF8.self))
            } catch {
                print("Failed to load URL from file: \(error.localizedDescription)")
                return []
            }
        }.value
    }

    static let FileParser = Parse {
        Many {
            Prefix(while: { !$0.isNewline }).compactMap(String.init)

        } separator: {
            Newline()
        }.map {
            $0.compactMap(URL.init(string:))
        }
    }
}
