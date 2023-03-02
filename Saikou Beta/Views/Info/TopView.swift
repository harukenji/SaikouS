//
//  TopView.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import SwiftUI
import Kingfisher

struct TopView: View {
    let cover: String
    let image: String
    let romajiTitle: String
    let status: String
    let width: CGFloat
    let height: CGFloat
    let showHeader: Bool
    let totalEpisodes: Int?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { reader in
                FillAspectImage(
                    url: URL(string: cover),
                    doesAnimateHorizontal: true
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
                        .init(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), location: 0),
                        .init(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), location: 1)]),
                    startPoint: UnitPoint(x: 0.5, y: -3.0616171314629196e-17),
                    endPoint: UnitPoint(x: 0.5, y: 0.9999999999999999)))
                .frame(width: width, height: height)
                .frame(maxWidth: width,maxHeight: height)
            
            HStack(alignment: .bottom) {
                ZStack(alignment: .bottomLeading) {
                    Color(hex: "#1c1c1c")
                    
                    Text(romajiTitle)
                        .lineLimit(1)
                        .font(.system(size: 20, weight: .heavy))
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                }
                .frame(width: width)
                .frame(minWidth: width, maxWidth: width, maxHeight: 120)
                
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        KFImage(URL(string: image))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 120, maxHeight: 180)
                            .cornerRadius(18)
                        
                        Spacer()
                            .frame(maxWidth: 20)
                        
                        VStack(alignment: .leading) {
                            Text(romajiTitle)
                                .font(.system(size: 18, weight: .heavy))
                                .lineSpacing(8.0)
                            
                            Spacer()
                                .frame(maxHeight: 20)
                            
                            Text(status)
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(Color(hex: "#c23d81"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        print("Hello button tapped!")
                    }) {
                        Text("ADD TO LIST")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(Color(hex: "#8ca7ff"))
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    HStack {
                        Text("Total of ")
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        Text(String(totalEpisodes ?? 0))
                            .padding(.leading, -8)
                            .font(.system(size: 16, weight: .heavy))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
                .frame(width: width, height: height)
                .frame(minWidth: width, maxWidth: width, maxHeight: height, alignment: .bottom)
            }
            .frame(maxWidth: width)
            .offset(x: showHeader ? width / 2 + 4 :  -(width / 2))
            .animation(.linear(duration: 0.1), value: showHeader)
        }
        .frame(height: height)
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView(cover: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/98659-u46B5RCNl9il.jpg", image: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/b98659-sH5z5RfMuyMr.png", romajiTitle: "Youkoso Jitsuryoku Shijou Shugi no Kyoushitsu e", status: "Completed", width: 400, height: 420, showHeader: false, totalEpisodes: 12)
    }
}
