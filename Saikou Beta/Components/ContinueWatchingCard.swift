//
//  ContinueWatchingCard.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import SwiftUI
import Kingfisher

struct ContinueWatchingCard: View {
    let image: String
    let title: String
    let width: CGFloat
    
    var body: some View {
        ZStack {
            KFImage(URL(string: image))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: width - 40, maxHeight: 100)
                .contentShape(Rectangle().path(in: CGRect(x: 0, y: 0, width: 0, height: 0)))
            
            Rectangle()
                .foregroundColor(.black.opacity(0.6))
            
            HStack {
                Text("Continue : Episode 1\n\(title)")
                    .lineLimit(2)
                    .lineSpacing(8.0)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .heavy))
                
                Spacer()
                    .frame(maxWidth: 20)
                
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 24)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxHeight: 100)
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .zIndex(0)
    }
}

struct ContinueWatchingCard_Previews: PreviewProvider {
    static var previews: some View {
        ContinueWatchingCard(image: "", title: "Title", width: 400)
    }
}
