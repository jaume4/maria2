// Aria2CTerminationStatus.swift
// Maria2

import Foundation

// https://github.com/RobotsAndPencils/XcodesApp/blob/main/Xcodes/Backend/Aria2CTerminationStatus.swift
// https://github.com/aria2/aria2/blob/master/src/error_code.h
enum Aria2CTerminationStatus: Int32, CustomStringConvertible {
    case undefined = -1
    case finished = 0
    case unknownError = 1
    case timeOut
    case resourceNotFound
    case maxFileNotFound
    case tooSlowDownloadSpeed
    case networkProblem
    case inProgress
    case cannotResume
    case notEnoughDiskSpace
    case pieceLengthChanged
    case duplicateDownload
    case duplicateInfoHash
    case fileAlreadyExists
    case fileRenamingFailed
    case fileOpenError
    case fileCreateError
    case fileIoError
    case dirCreateError
    case nameResolveError
    case metalinkParseError
    case ftpProtocolError
    case httpProtocolError
    case httpTooManyRedirects
    case httpAuthFailed
    case bencodeParseError
    case bittorrentParseError
    case magnetParseError
    case optionError
    case httpServiceUnavailable
    case jsonParseError
    case removed
    case checksumError

    init(exitStatus: Int32) {
        self = Aria2CTerminationStatus(rawValue: exitStatus) ?? .undefined
    }

    var isError: Bool {
        self != .finished
    }

    var description: String {
        switch self {
        case .undefined:
            return "Undefined"
        case .finished:
            return "Finished"
        case .unknownError:
            return "Unknown error"
        case .timeOut:
            return "Timed out"
        case .resourceNotFound:
            return "Resource not found"
        case .maxFileNotFound:
            return "Maximum number of file not found errors reached"
        case .tooSlowDownloadSpeed:
            return "Download speed too slow"
        case .networkProblem:
            return "Network problem"
        case .inProgress:
            return "Unfinished downloads in progress"
        case .cannotResume:
            return "Remote server did not support resume when resume was required to complete download"
        case .notEnoughDiskSpace:
            return "Not enough disk space available"
        case .pieceLengthChanged:
            return "Piece length was different from one in .aria2 control file"
        case .duplicateDownload:
            return "Duplicate download"
        case .duplicateInfoHash:
            return "Duplicate info hash torrent"
        case .fileAlreadyExists:
            return "File already exists"
        case .fileRenamingFailed:
            return "Renaming file failed"
        case .fileOpenError:
            return "Could not open existing file"
        case .fileCreateError:
            return "Could not create new file or truncate existing file"
        case .fileIoError:
            return "File I/O error"
        case .dirCreateError:
            return "Could not create directory"
        case .nameResolveError:
            return "Name resolution failed"
        case .metalinkParseError:
            return "Could not parse Metalink document"
        case .ftpProtocolError:
            return "FTP command failed"
        case .httpProtocolError:
            return "HTTP response header was bad or unexpected"
        case .httpTooManyRedirects:
            return "Too many redirects occurred"
        case .httpAuthFailed:
            return "HTTP authorization failed"
        case .bencodeParseError:
            return "Could not parse bencoded file (usually \".torrent\" file)"
        case .bittorrentParseError:
            return "\".torrent\" file was corrupted or missing information"
        case .magnetParseError:
            return "Magnet URI was bad"
        case .optionError:
            return "Bad/unrecognized option was given or unexpected option argument was given"
        case .httpServiceUnavailable:
            return "HTTP service unavailable"
        case .jsonParseError:
            return "Could not parse JSON-RPC request"
        case .removed:
            return "Reserved. Not used."
        case .checksumError:
            return "Checksum validation failed"
        }
    }
}
