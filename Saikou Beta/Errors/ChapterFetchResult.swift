//
//  ChapterFetchResult.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import Foundation

enum ChapterFetchResult {
    case success(data: [Chapter])
    case failure(error: AnilistFetchError)
}
