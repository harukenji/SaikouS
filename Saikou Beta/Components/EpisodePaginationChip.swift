//
//  EpisodePaginationChip.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import SwiftUI

struct EpisodePaginationChip: View {
    @State private var paginationIndex: Int
    @State private var startEpisodeList: Int
    @State private var endEpisodeList: Int
    let episodeCount: Int
    let index: Int
    
    init(paginationIndex: Int, startEpisodeList: Int, endEpisodeList: Int, episodeCount: Int, index: Int) {
        self.paginationIndex = paginationIndex
        self.startEpisodeList = startEpisodeList
        self.endEpisodeList = endEpisodeList
        self.episodeCount = episodeCount
        self.index = index
    }
    
    var body: some View {
        ZStack {
            Color(hex: index == paginationIndex ? "#8ca7ff" : "#1c1b1f")
            
            
            Text("\((50 * index) + 1) - " + String(50 + (50 * index) > episodeCount ? episodeCount : 50 + (50 * index)))
                .font(.system(size: 16, weight: .heavy))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
        }
        .fixedSize()
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.7), lineWidth: index == paginationIndex ? 0 : 1)
        )
        .onTapGesture {
            self.startEpisodeList = 50 * index
            self.endEpisodeList = 50 + (50 * index) > episodeCount ? episodeCount : 50 + (50 * index)
            self.paginationIndex = index
        }
    }
}

struct EpisodePaginationChip_Previews: PreviewProvider {
    static var previews: some View {
        EpisodePaginationChip(paginationIndex: 1, startEpisodeList: 0, endEpisodeList: 50, episodeCount: 50, index: 1)
    }
}
