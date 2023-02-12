//
//  SearchFetchResult.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

enum SearchFetchResult {
    case success(data: SearchResults)
    case failure(error: AnilistFetchError)
}
