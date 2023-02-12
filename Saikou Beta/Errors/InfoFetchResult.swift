//
//  InfoFetchResult.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

enum InfoFetchResult {
    case success(data: InfoData)
    case failure(error: AnilistFetchError)
}
