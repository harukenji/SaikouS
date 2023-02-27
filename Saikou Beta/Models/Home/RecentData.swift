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
    let image: String
    let rating: Int?
    let color: String?
    let episodeId: String?
    let episodeTitle: String?
    let episodeNumber: Int
    let genres: [String]
    let type: String
}
