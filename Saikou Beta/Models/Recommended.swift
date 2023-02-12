//
//  Recommended.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

struct Recommended: Codable {
    let id: Int?
    let malId: Int?
    let title: Title
    let status: String
    let episodes: Int?
    let image, cover: String
    let rating: Int?
    let type: String?
}
