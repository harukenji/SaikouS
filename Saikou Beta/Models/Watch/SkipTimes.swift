//
//  SkipTimes.swift
//  Saikou Beta
//
//  Created by Inumaki on 28.02.23.
//

import Foundation

struct SkipTimes: Codable {
    let found: Bool
    let results: [Skips]?
    let message: String?
    let statusCode: Int
}

struct Skips: Codable {
    let interval: Interval
    let skipType: String
    let skipId: String
    let episodeLength: CGFloat
}

struct Interval: Codable {
    let startTime: CGFloat
    let endTime: CGFloat
}
