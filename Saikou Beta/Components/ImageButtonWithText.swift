//
//  ImageButtonWithText.swift
//  Saikou Beta
//
//  Created by Inumaki on 01.03.23.
//

import SwiftUI
import Kingfisher

struct ImageButtonWithText: View {
    let image: String
    let text: String
    
    var body: some View {
        ZStack {
            KFImage(URL(string: image))
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            Color(.black.withAlphaComponent(0.7))
            
            VStack(spacing: 6) {
                Text(text)
                    .font(.system(size: 16, weight: .heavy))
                
                Rectangle()
                    .foregroundColor(Color(hex: "#ff4cb0"))
                    .frame(maxWidth: 72,maxHeight: 3)
            }
        }
        .frame(maxWidth: 162, maxHeight: 72)
        .frame(width: 162, height: 72)
        .clipped()
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
        )
    }
}

struct ImageButtonWithText_Previews: PreviewProvider {
    static var previews: some View {
        ImageButtonWithText(image: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/16498-8jpFCOcDmneX.jpg", text: "GENRES")
    }
}
