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
    
    @State private var finishedLoading: Bool = false
    
    public init(url: URL?) {
        self.url = url
    }
    
    public var body: some View {
        GeometryReader { proxy in
            KFImage.url(url)
                .onSuccess { image in
                    finishedLoading = true
                }
                .onFailure { _ in
                    finishedLoading = true
                }
                .resizable()
                .transaction { $0.animation = nil }
                .scaledToFill()
                .transition(.opacity)
                .opacity(finishedLoading ? 1.0 : 0.0)
                .background(Color(white: 0.05))
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    alignment: .center
                )
                .contentShape(Rectangle())
                .clipped()
                .animation(.easeInOut(duration: 0.5), value: finishedLoading)
        }
    }
}

struct FillAspectImage_Previews: PreviewProvider {
    static var previews: some View {
        FillAspectImage(url: URL(string: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/98659-u46B5RCNl9il.jpg"))
    }
}
