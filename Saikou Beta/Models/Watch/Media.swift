//
//  Media.swift
//  Saikou Beta
//
//  Created by Inumaki on 20.02.23.
//

import Foundation
import AVKit

struct Media: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    
    var asPlayerItem: AVPlayerItem {
        AVPlayerItem(url: URL(string: url)!)
    }
}
