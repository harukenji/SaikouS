//
//  RecentData.swift
//  Saikou Beta
//
//  Created by Inumaki on 27.02.23.
//

import Foundation

struct RecentData: Codable {
    let id: String
    let malId: Int?
    let title: Title
    let status: String
    let image: String
    let cover: String?
    let popularity: Int?
    let totalEpisodes: Int?
    let currentEpisode: Int?
    let countryOfOrigin: String?
    let description: String
    let genres: [String]
    let rating: Int?
    let color: String?
    let type: String
    let releaseDate: Int
}
