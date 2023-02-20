//
//  AnilistFetchError.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

enum AnilistFetchError: Error {
    case dataLoadFailed
    case dataParsingFailed(reason: Error)
    case invalidUrlProvided
}

extension AnilistFetchError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dataLoadFailed:
            return "Data parsing failed."
        case .invalidUrlProvided:
            return "The URL you provided is not valid."
        case .dataParsingFailed(reason: let reason):
            return "An unexpected error occurred. \(reason.localizedDescription)"
        }
    }
}
