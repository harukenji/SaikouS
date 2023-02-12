//
//  Episode.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

struct Episode: Codable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let number: Int?
    let image: String
    let isFiller: Bool?
}
