//
//  MangaFetchResult.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import Foundation

enum MangaFetchResult {
    case success(data: MangaInfoData)
    case failure(error: AnilistFetchError)
}
