//
//  AnimeCard.swift
//  Saikou Beta
//
//  Created by Inumaki on 15.02.23.
//

import SwiftUI
import Kingfisher
import Shimmer

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct AnimeCard: View {
    let image: String
    let rating: Int?
    let title: String
    let currentEpisodeCount: Int?
    let totalEpisodes: Int?
    let isMacos: Bool
    
    var animation: Namespace.ID?
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                KFImage(URL(string: image))
                    .placeholder({
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(Color(hex: "#444444"))
                            .frame(width: isMacos ? 170 : 110, height: isMacos ? 260 : 160)
                            .frame(maxWidth: isMacos ? 170 : 110, maxHeight: isMacos ? 260 : 160)
                            .cornerRadius(18)
                            .redacted(reason: .placeholder)
                            .shimmering()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isMacos ? 170 : 110, height: isMacos ? 260 : 160)
                    .frame(maxWidth: isMacos ? 170 : 110, maxHeight: isMacos ? 260 : 160)
                    .cornerRadius(16)
                    .if(animation != nil) { view in
                        view.matchedGeometryEffect(id: image, in: animation!)
                    }
                
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .foregroundColor(Color(hex: "#C0ff5dae"))
                    
                    Text(rating != nil ? String(format: "%.1f", Float(rating!) / 10) : "0.0")
                        .font(.system(size: isMacos ? 16 : 12, weight: .heavy))
                        .padding(.top, 8)
                        .padding(.leading, isMacos ? 22 : 19)
                }
                .frame(maxHeight: 60, alignment: .topLeading)
                .clipShape(
                    RoundCorner(
                        cornerRadius: 40,
                        maskedCorners: [.topLeft]
                    )//OUR CUSTOM SHAPE
                )
                .padding(.leading, isMacos ? 100 : 60)
                .padding(.bottom, -30)
            }
            .frame(maxWidth: isMacos ? 170 : 110, maxHeight: isMacos ? 260 : 160)
            .cornerRadius(16)
            .clipped()
            
            Text(title)
                .frame(maxWidth: isMacos ? 170 : 110, alignment: .leading)
                .lineLimit(3)
                .font(.system(size: isMacos ? 18 : 14))
                .multilineTextAlignment(.leading)
            
            HStack {
                Text(currentEpisodeCount != nil ? String(currentEpisodeCount!) : "~")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#8da2f8"))
                + Text(totalEpisodes != nil ? " | " + String(totalEpisodes!) : " | ~")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: isMacos ? 170 : 110, alignment: .leading)
        }
        .foregroundColor(.white)
    }
}


struct AnimeCard_Previews: PreviewProvider {
    static var previews: some View {
        AnimeCard(image: "", rating: nil, title: "", currentEpisodeCount: nil, totalEpisodes: nil, isMacos: false)
    }
}
