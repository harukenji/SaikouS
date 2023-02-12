//
//  Name.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

struct Name: Codable {
    let first, last, full: String?
    let native: String?
    let userPreferred: String
}
