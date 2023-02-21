//
//  StreamData.swift
//  Saikou Beta
//
//  Created by Inumaki on 20.02.23.
//

import Foundation

struct StreamData: Codable {
    let headers: header?
    let sources: [source]?
    let subtitles: [subtitle]?
}
