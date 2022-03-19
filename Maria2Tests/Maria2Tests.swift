// Maria2Tests.swift
// Maria2

@testable import Maria2
import XCTest

class Maria2Tests: XCTestCase {
    func testProgressReportParsing() throws {
        let aria2progressReport = """
                  *** Download Progress Summary as of Sat Mar 12 22:22:09 2022 ***
                 ===============================================================================
                 [#ae8c88 401686528B/514843208B(78%) CN:9 DL:6035885B ETA:3h2m18s]
                 FILE: /Users/jaume/Downloads/TEST.ipa
                 -------------------------------------------------------------------------------
        """

        let output = try Aria2Progress.OutputParse.parse(aria2progressReport[...])

        let expected = ProgressReport(progress: 78,
                                      channels: 9,
                                      speed: 6_035_885,
                                      eta: 3 * 60 * 60 + 2 * 60 + 18,
                                      total: 514_843_208,
                                      downloaded: 401_686_528)

        if case let .update(report) = output {
            XCTAssertEqual(expected, report)
        } else {
            XCTFail("didn't parse update report")
        }
    }

    func testRenamingParsing() throws {
        /* report contains unprintable ascii characters so using data instead
         03/12 22:26:09 [[1;32mNOTICE[0m] File already exists. Renamed to /Users/jaume/Downloads/TEST.1.ipa.
         */
        let aria2progressReportData = "MDMvMTIgMjI6MjY6MDkgWxtbMTszMm1OT1RJQ0UbWzBtXSBGaWxlIGFscmVhZHkgZXhpc3RzLiBSZW5hbWVkIHRvIC9Vc2Vycy9qYXVtZS9Eb3dubG9hZHMvVEVTVC4xLmlwYS4K"
        let aria2progressReport = String(decoding: Data(base64Encoded: aria2progressReportData)!, as: UTF8.self)

        let output = try Aria2Progress.OutputParse.parse(aria2progressReport[...])

        if case let .renamed(path) = output {
            XCTAssertEqual("/Users/jaume/Downloads/TEST.1.ipa", path)
        } else {
            XCTFail("didn't parse renaming report")
        }
    }
}
