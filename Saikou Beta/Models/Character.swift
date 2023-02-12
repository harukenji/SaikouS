//
//  Character.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import Foundation

struct Character: Codable {
    let id: Int?
    let role: String
    let name: Name
    let image: String
    let voiceActors: [VoiceActor]?
}
