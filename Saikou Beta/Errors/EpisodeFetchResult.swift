//
//  EpisodeFetchResult.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

enum EpisodeFetchResult {
    case success(data: [Episode])
    case failure(error: AnilistFetchError)
}
