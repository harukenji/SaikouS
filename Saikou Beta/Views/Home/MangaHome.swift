//
//  MangaHome.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import SwiftUI

//
//  AnimeHome.swift
//  Saikou Beta
//
//  Created by Inumaki on 27.02.23.
//

import SwiftUI
import Kingfisher
import ActivityIndicatorView

struct MangaHome: View {
    let proxy: GeometryProxy
    @StateObject var viewModel: MangaHomeViewModel = MangaHomeViewModel()
    
    var body: some View {
        ScrollView {
                ZStack(alignment: .top) {
                    Color(.black)
                    
                    KFImage(URL(string: "https://s4.anilist.co/file/anilistcdn/media/manga/banner/100994-mEIqjSzFKysR.jpg"))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: proxy.size.width, maxHeight: 500)
                        .blur(radius: 8)
                    
                    Rectangle().fill(LinearGradient(colors: [.black.opacity(0.0), Color(.black)], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 0.0, y: 1.0)))
                        .frame(maxHeight: 510)
                    
                    VStack(alignment: .leading) {
                        
                        // input, which seems to just be a button
                        HStack {
                            NavigationLink(destination: MangaSearch(proxy: proxy)) {
                                ZStack {
                                    Color(.black.withAlphaComponent(0.4))
                                    
                                    HStack {
                                        Text("MANGA")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .heavy))
                                            .padding(.vertical, 16)
                                            .padding(.leading, 20)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .bold))
                                            .padding(.trailing, 20)
                                    }
                                    .frame(maxWidth: 280, alignment: .leading)
                                    .frame(width: 280)
                                }
                                .fixedSize()
                                .cornerRadius(40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                            
                            Button(action: {}) {
                                ZStack {
                                    Color(.black.withAlphaComponent(0.4))
                                    
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 28))
                                        .padding(10)
                                }
                                .fixedSize()
                                .cornerRadius(40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                        }
                        .padding(.bottom, 30)
                        .padding(.top, 80)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(alignment: .bottom, spacing: 20) {
                                ZStack(alignment: .bottomTrailing) {
                                    KFImage(URL(string: "https://s4.anilist.co/file/anilistcdn/media/manga/cover/large/bx100994-f6CMjiQQNVeS.png"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 190)
                                        .frame(maxWidth: 120, maxHeight: 190)
                                        .cornerRadius(16)
                                    
                                    ZStack(alignment: .topLeading) {
                                        Rectangle()
                                            .foregroundColor(Color(hex: "#C0ff5dae"))
                                        
                                        Text("8.2")
                                            .font(.system(size: 14, weight: .heavy))
                                            .padding(.top, 8)
                                            .padding(.leading, 22)
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
                                .frame(maxWidth: 120, maxHeight: 190)
                                .cornerRadius(16)
                                .clipped()
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Jigokuraku")
                                        .font(.system(size: 18, weight: .heavy))
                                    
                                    Text("Completed")
                                        .font(.system(size: 16, weight: .heavy))
                                        .foregroundColor(Color(hex: "#ff4caf"))
                                }
                            }
                            
                            HStack {
                                Text("127 / 127")
                                    .font(.system(size: 16))
                                + Text(" Chapters")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 16))
                                Spacer()
                                Text("Action • Adventure • Mystery")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 16))
                                    .frame(maxWidth: 150)
                            }
                            .padding(.trailing, 30)
                            
                            Spacer()
                                .frame(maxHeight: 20)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Color(hex: "#1c1b1f")
                                        Text("This Season")
                                            .font(.system(size: 16, weight: .heavy))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 14)
                                    }
                                    .fixedSize()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1.4)
                                    )
                                    ZStack {
                                        Color(hex: "#1c1b1f")
                                        Text("Next Season")
                                            .font(.system(size: 16, weight: .heavy))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 14)
                                    }
                                    .fixedSize()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1.4)
                                    )
                                    ZStack {
                                        Color(hex: "#1c1b1f")
                                        Text("Previous Season")
                                            .font(.system(size: 16, weight: .heavy))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 14)
                                    }
                                    .fixedSize()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1.4)
                                    )
                                }
                            }
                            
                            HStack {
                                ImageButtonWithText(image: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/16498-8jpFCOcDmneX.jpg", text: "GENRES")
                                
                                Spacer()
                                
                                ImageButtonWithText(image: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/125367-hGPJLSNfprO3.jpg", text: "CALENDAR")
                            }
                            .padding(.trailing, 30)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                            .frame(maxHeight: 20)
                        
                        Text("Recently Uploaded")
                            .font(.system(size: 18, weight: .heavy))
                        
                        Spacer()
                            .frame(maxHeight: 20)
                        
                        if(viewModel.recentresults != nil && viewModel.recentresults!.results.count > 0) {
                            ScrollView(.horizontal) {
                                HStack(spacing: 20) {
                                    ForEach(0..<viewModel.recentresults!.results.count) { index in
                                        AnimeCard(image: viewModel.recentresults!.results[index].image, rating: viewModel.recentresults!.results[index].rating, title: viewModel.recentresults!.results[index].title.romaji, currentEpisodeCount: viewModel.recentresults!.results[index].currentEpisode, totalEpisodes: viewModel.recentresults!.results[index].totalEpisodes)
                                    }
                                }
                            }
                            .padding(.bottom, 140)
                        }
                    }
                    .padding(.leading, 30)
                    .frame(maxWidth: proxy.size.width, maxHeight: .infinity, alignment: .top)
                }
        }
        .ignoresSafeArea()
        .onAppear {
            Task {
                print("Getting recent episodes")
                await viewModel.fetchRecentChapters()
            }
        }
    }
}

struct MangaHome_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader {proxy in
            MangaHome(proxy: proxy)
        }
    }
}

