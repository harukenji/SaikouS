//
//  Title.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

struct Title: Codable, Hashable {
    let romaji: String
    var english: String?
    let native: String?
    var userPreferred: String?
}
