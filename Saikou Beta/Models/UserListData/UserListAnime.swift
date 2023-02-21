//
//  UserListAnime.swift
//  Saikou Beta
//
//  Created by Inumaki on 13.02.23.
//

import Foundation


struct userInfoData: Codable {
    let data: UserViewer
}

struct UserViewer: Codable {
    let Viewer: UserViewerData
}

struct UserViewerData: Codable {
    let id: Int
    let name: String
    let avatar: Avatar
    let bannerImage: String?
    let statistics: Statistics
}

struct Avatar: Codable {
    let large: String
}

struct Statistics: Codable {
    let anime: AnimeStatistics
}

struct AnimeStatistics: Codable {
    let episodesWatched: Int
}

struct userList: Codable {
    let data: MediaData
}

struct MediaData: Codable {
    let MediaListCollection: MediaListCollection
}

struct MediaListCollection : Codable {
    let lists: [AnimeList]?
}

struct AnimeList: Codable {
    let name: String
    let isCustomList: Bool
    let isCompletedList: Bool
    let entries: [AnimeEntry]
}

struct AnimeEntry: Codable {
    let progress: Int
    let media: AnimeMedia
}

struct AnimeMedia: Codable {
    let id: Int
    let title: Title
    let coverImage: CoverImage
    let episodes: Int
    let averageScore: Int
}

struct CoverImage: Codable {
    let extraLarge: String
    let large: String
}
