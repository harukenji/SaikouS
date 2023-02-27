//
//  FakeHome.swift
//  Saikou Beta
//
//  Created by Inumaki on 27.02.23.
//

import SwiftUI

struct homeItem: Codable, Identifiable {
    let id: String
    let artwork: String
    let platformTitle: String
    let bannerTitle: String
    let appLogo: String
    let appName: String
    let appDescription: String
}

struct FakeHome: View {
    let todayItems = [
        homeItem(id: "1", artwork: "anime_pfp_boy_1", platformTitle: "Title 1", bannerTitle: "Banner Title 1", appLogo: "anime_pfp_girl_1", appName: "App Name", appDescription: "App Description"),
        homeItem(id: "2", artwork: "anime_pfp_boy_2", platformTitle: "Title 2", bannerTitle: "Banner Title 2", appLogo: "anime_pfp_girl_1", appName: "App Name", appDescription: "App Description"),
        homeItem(id: "3", artwork: "anime_pfp_girl_1", platformTitle: "Title 3", bannerTitle: "Banner Title 3", appLogo: "anime_pfp_girl_1", appName: "App Name", appDescription: "App Description")
    ]
    
    // MARK: Animation Properties
    @State var currentItem: homeItem?
    @State var showDetailPage: Bool = false
    
    // Matched Geometry Effect
    @Namespace var animation
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MONDAY 4 APRIL")
                            .font(.callout)
                            .foregroundColor(.gray)
                        
                        Text("Today")
                            .font(.largeTitle.bold())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button{
                        
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                ForEach(todayItems) { item in
                    Button {
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                            currentItem = item
                            showDetailPage = true
                        }
                    } label: {
                        CardView(item: item)
                            .scaleEffect(currentItem?.id == item.id && showDetailPage ? 1 : 0.93)
                    }
                    .buttonStyle(ScaledButtonStyle())
                }
            }
            .padding(.vertical)
        }
        .overlay {
            if let currentItem = currentItem, showDetailPage {
                DetailView(item: currentItem)
            }
        }
    }
    
    //MARK: CardView
    @ViewBuilder
    func CardView(item: homeItem) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            ZStack(alignment: .topLeading) {
                // Banner Image
                GeometryReader {proxy in
                    let size = proxy.size
                    
                    Image(item.artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipped()
                        .clipShape(RoundCorner(cornerRadius: 15, maskedCorners: [.topLeft, .topRight]))
                }
                .frame(height: 400)
                
                LinearGradient(colors: [
                
                    .black.opacity(0.5),
                    .black.opacity(0.2),
                    .clear
                ], startPoint: .top, endPoint: .bottom)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.platformTitle.uppercased())
                        .font(.callout)
                        .fontWeight(.semibold)
                    
                    Text(item.bannerTitle)
                        .font(.largeTitle.bold())
                }
                .foregroundColor(.white)
                .padding()
            }
            
            HStack(spacing: 12) {
                Image(item.appLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.platformTitle.uppercased())
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(item.appName)
                        .fontWeight(.bold)
                    
                    Text(item.appDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    
                } label: {
                    Text("Get")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                        }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color(hex: "#222222"))
        }
        .matchedGeometryEffect(id: item.id, in: animation)
    }
    
    //MARK: Detail View
    func DetailView(item: homeItem) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                CardView(item: item)
            }
        }
        .transition(.identity)
    }
}

struct FakeHome_Previews: PreviewProvider {
    static var previews: some View {
        FakeHome()
    }
}

// MARK: ScaledButtonStyle
struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}
