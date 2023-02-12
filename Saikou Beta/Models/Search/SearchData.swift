//
//  SearchData.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

struct SearchData: Codable {
    let id: String
    let malId: Int?
    let title: Title
    let status: String
    let image: String
    let cover: String?
    let popularity: Int
    let description: String?
    let rating: Int?
    let genres: [String]
    let color: String?
    let totalEpisodes: Int?
    let currentEpisodeCount: Int?
    let type: String?
    let releaseDate: Int?
}
