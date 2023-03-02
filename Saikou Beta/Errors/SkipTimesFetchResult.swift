//
//  SkipTimesFetchResult.swift
//  Saikou Beta
//
//  Created by Inumaki on 28.02.23.
//

import Foundation

enum SkipTimesFetchResult {
    case success(data: SkipTimes)
    case failure(error: AnilistFetchError)
}
