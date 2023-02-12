//
//  EpisodeCard.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import SwiftUI
import Kingfisher

enum EpisodeCardType {
    case GRID
    case LIST
}

struct EpisodeCard: View {
    let image: String
    let episodeIndex: Int
    let title: String
    let description: String
    let episodeNumber: Int
    let selectedProvider: String
    let id: String
    let index: Int
    @Binding var lineLimitArray: [Int]
    let viewModel: InfoViewModel
    let type: EpisodeCardType
    
    init(image: String, episodeIndex: Int, title: String, description: String, episodeNumber: Int, selectedProvider: String, id: String, index: Int, lineLimitArray: Binding<[Int]>, viewModel: InfoViewModel, type: EpisodeCardType) {
        self.image = image
        self.episodeIndex = episodeIndex
        self.title = title
        self.description = description
        self.episodeNumber = episodeNumber
        self.selectedProvider = selectedProvider
        self.id = id
        self.index = index
        _lineLimitArray = lineLimitArray
        self.viewModel = viewModel
        self.type = type
    }
    
    var body: some View {
        if(type == .LIST) {
            ZStack(alignment: .topLeading) {
                Color(hex: "#282828")
                
                VStack {
                    NavigationLink(destination: WatchPage(aniData: viewModel.infodata!, episodeIndex: episodeIndex, anilistId: id, provider: selectedProvider)) {
                        HStack {
                            KFImage(URL(string: image))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 170)
                                .cornerRadius(12)
                            
                            Text(title)
                                .font(.system(size: 14, weight: .heavy))
                                .frame(maxWidth: .infinity)
                                .padding(.trailing, 20)
                                .lineLimit(4)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text(description)
                        .lineLimit(self.lineLimitArray.count > 0 ? self.lineLimitArray[index] : 3)
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 14, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .animation(.spring(response: 0.3))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .padding(.bottom, 8)
                        .onTapGesture {
                            self.lineLimitArray[index] = self.lineLimitArray[index] == 3 ? 100 : 3
                        }
                }
                
                ZStack {
                    Color(.white)
                    
                    Text(String(episodeNumber))
                        .foregroundColor(.black)
                        .font(.system(size: 24, weight: .heavy))
                        .padding(6)
                }
                .fixedSize()
                .cornerRadius(30, corners: [.bottomRight])
            }
            .cornerRadius(12)
            .padding(.bottom, 8)
        } else if(type == .GRID) {
            NavigationLink(destination: WatchPage(aniData: viewModel.infodata!, episodeIndex: episodeIndex, anilistId: id, provider: selectedProvider)) {
                ZStack {
                    KFImage(URL(string: image))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 170, maxHeight: 120)
                        .cornerRadius(20)
                    
                    Rectangle()
                        .frame(maxWidth: 170, maxHeight: 120)
                        .cornerRadius(20)
                        .foregroundColor(.black.opacity(0.6))
                    
                    ZStack(alignment: .topLeading) {
                        Text(title)
                            .font(.system(size: 16, weight: .heavy))
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .padding(.top, -40)
                            .frame(width: 170, height: 120)
                            .frame(maxWidth: 170, maxHeight: 120, alignment: .topLeading)
                        
                        Text(String(episodeNumber))
                            .font(.system(size: 62, weight: .heavy))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(width: 170, height: 120, alignment: .bottomTrailing)
                            .frame(maxWidth: 170, maxHeight: 120, alignment: .bottomTrailing)
                            .padding(.bottom, -4)
                            .padding(.trailing, 12)
                    }
                    .frame(maxWidth: 170, maxHeight: 120)
                }
                .frame(maxWidth: 170, maxHeight: 120)
                .cornerRadius(20)
                .clipped()
            }
        }
    }
}
