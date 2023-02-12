//
//  SearchResult.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

struct SearchResults: Codable {
    let currentPage: Int
    let hasNextPage: Bool
    let results: [SearchData]
}
