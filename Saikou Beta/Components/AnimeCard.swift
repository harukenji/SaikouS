//
//  AnimeCard.swift
//  Saikou Beta
//
//  Created by Inumaki on 15.02.23.
//

import SwiftUI
import Kingfisher

struct AnimeCard: View {
    let image: String
    let rating: Int?
    let title: String
    let currentEpisodeCount: Int?
    let totalEpisodes: Int?
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                KFImage(URL(string: image))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 160)
                    .frame(maxWidth: 110, maxHeight: 160)
                    .cornerRadius(16)
                
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .foregroundColor(Color(hex: "#C0ff5dae"))
                    
                    Text(rating != nil ? String(format: "%.1f", Float(rating!) / 10) : "0.0")
                        .font(.system(size: 12, weight: .heavy))
                        .padding(.top, 8)
                        .padding(.leading, 19)
                }
                .frame(maxHeight: 60, alignment: .topLeading)
                .clipShape(
                    RoundCorner(
                        cornerRadius: 40,
                        maskedCorners: [.topLeft]
                    )//OUR CUSTOM SHAPE
                )
                .padding(.leading, 60)
                .padding(.bottom, -30)
            }
            .frame(maxWidth: 110, maxHeight: 160)
            .cornerRadius(16)
            .clipped()
            
            Text(title)
                .frame(maxWidth: 110, alignment: .leading)
                .lineLimit(3)
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
            HStack {
                Text(currentEpisodeCount != nil ? String(currentEpisodeCount!) : "~")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#8da2f8"))
                
                Text(totalEpisodes != nil ? "| " + String(totalEpisodes!) : "| ~")
                    .font(.system(size: 16))
                    .foregroundColor(.white).opacity(0.7)
                    .padding(.leading, -3)
            }
            .frame(maxWidth: 110, alignment: .leading)
        }
        .foregroundColor(.white)
    }
}


struct AnimeCard_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCard(image: "", rating: nil, title: "", currentEpisodeCount: nil, totalEpisodes: nil)
    }
}
