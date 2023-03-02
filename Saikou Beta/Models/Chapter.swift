//
//  Chapter.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import Foundation

struct Chapter: Codable {
    let id: String
    let title: String?
    let chapterNumber: String?
    let volumeNumber: String?
    let pages: Int
}
