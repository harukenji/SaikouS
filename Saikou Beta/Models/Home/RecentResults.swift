//
//  RecentResults.swift
//  Saikou Beta
//
//  Created by Inumaki on 27.02.23.
//

import Foundation

struct RecentResults: Codable {
    let currentPage: Int?
    let hasNextPage: Bool?
    let totalPages: Int?
    let totalResults: Int?
    var results: [RecentData]
}
