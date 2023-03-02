//
//  InfoData.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

struct InfoData: Codable {
    let id: String
    let title: Title
    let malId: Int?
    let synonyms: [String]?
    let isLicensed, isAdult: Bool?
    let countryOfOrigin: String?
    let trailer: Trailer?
    let image: String
    let popularity: Int
    let color: String?
    let cover: String
    let description, status: String
    let releaseDate: Int
    let startDate: Date
    let endDate: Date?
    let nextAiringEpisode: AiringData?
    let totalEpisodes: Int?
    let currentEpisodeCount: Int?
    let duration: Int?
    let rating: Int?
    let genres: [String]
    let season: String?
    let studios: [String]
    let subOrDub: String?
    let type: String?
    let recommendations: [Recommended]?
    let characters: [Character]
    let relations: [Related]?
    var episodes: [Episode]?
}

struct MangaInfoData: Codable {
    let id: String
    let title: Title
    let malId: Int?
    let synonyms: [String]?
    let isLicensed, isAdult: Bool?
    let countryOfOrigin: String?
    let trailer: Trailer?
    let image: String
    let popularity: Int
    let color: String?
    let cover: String
    let description, status: String
    let releaseDate: Int
    let startDate: Date
    let endDate: Date?
    let nextAiringEpisode: AiringData?
    let totalEpisodes: Int?
    let currentEpisodeCount: Int?
    let duration: Int?
    let rating: Int?
    let genres: [String]
    let season: String?
    let studios: [String]
    let subOrDub: String?
    let type: String?
    let recommendations: [Recommended]?
    let characters: [Character]
    let relations: [Related]?
    var chapters: [Chapter]?
}
