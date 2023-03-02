//
//  AnilistInfoTopBanner.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import SwiftUI
import Kingfisher

struct AnilistInfoTopBanner: View {
    let user: userData
    let width: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { reader in
                FillAspectImage(
                    url: URL(string: user.banner),
                    doesAnimateHorizontal: false
                )
                .frame(
                    width: reader.size.width,
                    height: reader.size.height + (reader.frame(in: .global).minY > 0 ? reader.frame(in: .global).minY : 0),
                    alignment: .center
                )
                .contentShape(Rectangle())
                .clipped()
                .offset(y: reader.frame(in: .global).minY <= 0 ? 0 : -reader.frame(in: .global).minY)
            }
            
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "#00000000"), location: 0),
                        .init(color: Color(hex: "#ff000000"), location: 1)]),
                    startPoint: UnitPoint(x: 0, y: 0),
                    endPoint: UnitPoint(x: 0, y: 1)))
                .frame(maxWidth: width, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .fontWeight(.heavy)
                        
                        HStack {
                            Text("Episodes watched")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 12))
                            Text("\(user.episodesWatched)")
                                .foregroundColor(Color(hex: "#91a6ff"))
                                .font(.system(size: 12, weight: .heavy))
                                .padding(.leading, -4)
                        }
                        HStack {
                            Text("Chapters read")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 12))
                            Text("\(user.chaptersRead)")
                                .foregroundColor(Color(hex: "#91a6ff"))
                                .font(.system(size: 12, weight: .heavy))
                                .padding(.leading, -4)
                        }
                    }
                    
                    Spacer()
                    
                    KFImage(URL(string: user.avatar))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 40, maxHeight: 40)
                        .cornerRadius(40)
                }
                .frame(maxWidth: width - 40)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                
                HStack {
                    ImageButtonWithText(image: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/114535-ASUprf4AsNwC.jpg", text: "ANIME LIST")
                    
                    Spacer()
                    
                    ImageButtonWithText(image: "https://s4.anilist.co/file/anilistcdn/media/manga/banner/101606-OXPYcB9KD9qT.png", text: "MANGA LIST")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(width: width, height: 210, alignment: .bottom)
            .frame(maxWidth: width, maxHeight: 210, alignment: .bottom)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: width)
        .frame(height: 210)
    }
}

struct AnilistInfoTopBanner_Previews: PreviewProvider {
    static var previews: some View {
        AnilistInfoTopBanner(user: userData(id: 0, name: "ryusakiL", avatar: "https://s4.anilist.co/file/anilistcdn/user/avatar/large/b661655-8diuHQsHwEOY.jpg", banner: "https://s4.anilist.co/file/anilistcdn/user/banner/b661655-G9qEj8RiWE4X.jpg", episodesWatched: 0, chaptersRead: 0), width: 393)
    }
}
