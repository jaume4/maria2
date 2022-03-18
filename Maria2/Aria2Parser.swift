// Aria2Parser.swift
// Maria2

import Parsing

struct ProgressReport: Equatable {
    let progress: Int
    let channels: Int
    let speed: Int
    let eta: Int
    let total: Int
    let downloaded: Int
}

enum Aria2Progress {
    case update(ProgressReport)
    case renamed(String)
    case finished(Aria2CTerminationStatus)

    static let OutputParse = Parse {
        OneOf {
            updateParse
            renamedParse
        }
    }

    private static let updateParse = Parse {
        /*
          *** Download Progress Summary as of Sat Mar 12 22:22:09 2022 ***
         ===============================================================================
         [#ae8c88 401686528B/514843208B(78%) CN:9 DL:6035885B ETA:3h2m18s]
         FILE: /Users/jaume/Downloads/TEST.ipa
         -------------------------------------------------------------------------------
          */

        // Downloaded / Total
        Parse {
            Skip {
                PrefixThrough("[#".utf8)
                PrefixThrough(" ".utf8)
            }
            Int.parser()
            "B/".utf8
            Int.parser()
        }

        // % completed
        Parse {
            Skip {
                PrefixThrough("(".utf8)
            }
            Int.parser()
        }

        // channels
        Parse {
            Skip {
                PrefixThrough("CN:".utf8)
            }
            Int.parser()
        }

        // speed
        Parse {
            Skip {
                PrefixThrough("DL:".utf8)
            }
            Int.parser()
        }

        // ETA
        Parse {
            Skip {
                PrefixThrough("ETA:".utf8)
            }

            timeParse
        }

        // Rest
        Skip {
            Rest()
        }
    }.map { arg0, completed, channels, speed, eta -> Aria2Progress in
        let (downloaded, total) = arg0

        let report = ProgressReport(progress: completed, channels: channels, speed: speed, eta: eta, total: total, downloaded: downloaded)
        return Aria2Progress.update(report)
    }

    private static let renamedParse = Parse {
        /*
         03/12 22:26:09 [[1;32mNOTICE[0m] File already exists. Renamed to /Users/jaume/Downloads/TEST.1.ipa.

         */
        Skip {
            PrefixThrough("File already exists. Renamed to ".utf8)
        }

        PrefixUpTo(".\n".utf8).compactMap(String.init)
        Skip {
            Rest()
        }
    }.map(Aria2Progress.renamed)

    private static let timeParse = Parse {
        Many(atLeast: 1) {
            Int.parser(of: Substring.UTF8View.self)
            Units.parser()
        }.map { values in
            values.reduce(into: 0) { result, timeUnit in
                let (time, unit) = timeUnit
                switch unit {
                case .seconds: result += time
                case .minute: result += time * 60
                case .hour: result += time * 60 * 60
                }
            }
        }
    }

    enum Units: String, CaseIterable {
        case hour = "h"
        case minute = "m"
        case seconds = "s"
    }
}
