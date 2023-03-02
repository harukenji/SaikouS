//
//  Favourites.swift
//  Saikou Beta
//
//  Created by Inumaki on 01.03.23.
//

import Foundation

struct favourites: Codable {
    let data: favouritesData
}

struct favouritesData: Codable {
    let User: favouritesUser
}

struct favouritesUser: Codable {
    let id: Int
    let favourites: favouritesField
}

struct favouritesField: Codable {
    let anime: favouritesAnime
}

struct favouritesAnime: Codable {
    let pageInfo: PageInfo
    let edges: [favouritesEdge]
}

struct favouritesEdge: Codable {
    let favouriteOrder: Int
    let node: favouritesNode
}

struct favouritesNode: Codable {
    let id: Int
    let idMal: Int
    let isAdult: Bool
    let nextAiringEpisode: NextAiringEpisode?
    let episodes: Int
    let meanScore: Int
    let title: Title
    let type: String
    let status: String
    let bannerImage: String
    let coverImage: CoverImage
}

struct NextAiringEpisode: Codable {
    let episode: Int?
}

struct PageInfo: Codable {
    let hasNextPage: Bool
}
