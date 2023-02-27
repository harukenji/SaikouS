//
//  FillAspectImage.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import SwiftUI
import Kingfisher

public struct FillAspectImage: View {
    let url: URL?
    let doesAnimateHorizontal: Bool?
    
    let timer = Timer.publish(every: 25, on: .main, in: .common).autoconnect()
    @State private var finishedLoading: Bool = false
    @State private var imageWidth: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var animLeft: Bool = false
    
    public init(url: URL?, doesAnimateHorizontal: Bool) {
        self.url = url
        self.doesAnimateHorizontal = doesAnimateHorizontal
    }
    
    public var body: some View {
        GeometryReader { proxy in
            KFImage.url(url)
                .onSuccess { image in
                    finishedLoading = true
                    imageWidth = doesAnimateHorizontal! ? image.image.size.width : 0
                    if(doesAnimateHorizontal!) {
                        animLeft.toggle()
                        if(animLeft) {
                            self.offset = (imageWidth / 2 - (proxy.size.width / 2))
                        } else {
                            self.offset = -(imageWidth / 2 - (proxy.size.width / 2))
                        }
                    }
                }
                .onFailure { _ in
                    finishedLoading = true
                }
                .resizable()
                .scaledToFill()
                .offset(x: offset)
                .animation(doesAnimateHorizontal! ? .easeInOut(duration: 22) : nil, value: animLeft)
                .transition(.opacity)
                .opacity(finishedLoading ? 1.0 : 0.0)
                .background(Color(white: 0.05))
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    alignment: .center
                )
                .contentShape(Rectangle())
                .onReceive(timer) {time in
                    animLeft.toggle()
                        if(animLeft) {
                            self.offset = (imageWidth / 2 - (proxy.size.width / 2))
                        } else {
                            self.offset = -(imageWidth / 2 - (proxy.size.width / 2))
                        }
                    
                }
                .clipped()
                .animation(.easeInOut(duration: 0.5), value: finishedLoading)
                
        }
    }
}

struct FillAspectImage_Previews: PreviewProvider {
    static var previews: some View {
        FillAspectImage(url: URL(string: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/98659-u46B5RCNl9il.jpg"), doesAnimateHorizontal: true)
    }
}
