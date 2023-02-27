//
//  Search.swift
//  Saikou Beta
//
//  Created by Inumaki on 04.02.23.
//

import SwiftUI
import Kingfisher
import WebKit
import AuthenticationServices
import Combine

struct Search: View {
    let proxy: GeometryProxy
    @State var query = ""
    @StateObject var anilist: Anilist = Anilist()
    @ObservedObject var viewModel: SearchViewModel = SearchViewModel()
    @State var focused = false
    
    @State var resultDisplayGrid = true
    @State private var selectedItem = 1
    @State private var showingPopover = false
    
    let supportedGenres = [
        "Action",
        "Adventure",
        "Cars",
        "Comedy",
        "Drama",
        "Fantasy",
        "Horror",
        "Mahou Shoujo",
        "Mecha",
        "Music",
        "Mystery",
        "Psychological",
        "Romance",
        "Sci-Fi",
        "Slice of Life",
        "Sports",
        "Supernatural",
        "Thriller"
    ]
    let supportedSorting = [
        "POPULARITY_DESC",
        "POPULARITY",
        "TRENDING_DESC",
        "TRENDING",
        "UPDATED_AT_DESC",
        "UPDATED_AT",
        "START_DATE_DESC",
        "START_DATE",
        "END_DATE_DESC",
        "END_DATE",
        "FAVOURITES_DESC",
        "FAVOURITES",
        "SCORE_DESC",
        "SCORE",
        "TITLE_ROMAJI_DESC",
        "TITLE_ROMAJI",
        "TITLE_ENGLISH_DESC",
        "TITLE_ENGLISH",
        "TITLE_NATIVE_DESC",
        "TITLE_NATIVE",
        "EPISODES_DESC",
        "EPISODES",
        "ID",
        "ID_DESC"
    ]
    let supportedFormats = [
        "TV",
        "TV_SHORT",
        "OVA",
        "ONA",
        "MOVIE",
        "SPECIAL",
        "MUSIC"
    ]
    let minYear = 1970
    let maxYear = 2023
    
    @State var selectedYear: String = ""
    @State var selectedSeason: String = ""
    @State var selectedSorting: String = ""
    @State var selectedFormat: String = ""
    @State var selectedGenres: [String] = []
    
    let columns = [
        GridItem(.adaptive(minimum: 100), alignment: .top)
    ]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    ZStack {
                        TextField("Search for an anime...", text: $query, onEditingChanged: { (editingChanged) in
                            focused = editingChanged
                            print(focused)
                        })
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(focused ? Color(hex: "#ff4cb0") : Color.white.opacity(0.7), lineWidth: focused ? 2 : 1)
                        )
                        .onSubmit {
                            Task {
                                await anilist.search(query: query.replacingOccurrences(of: " ", with: "%20"), year: selectedYear, season: selectedSeason, genres: selectedGenres, format: selectedFormat, sort_by: selectedSorting)
                            }
                        }
                        .animation(.spring())
                        
                        ZStack {
                            Color(.black)
                            
                            Text("ANIME")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(focused ? Color(hex: "#ff4cb0") : Color(hex: "#8b8789"))
                                .padding(.horizontal, 6)
                                .animation(.spring())
                        }
                        .fixedSize()
                        .padding(.trailing, 270)
                        .padding(.bottom, 46)
                        
                    }
                    .padding(.bottom, 10)
                    
                    HStack {
                        Button(action: {
                            showingPopover = true
                        }) {
                            ZStack {
                                Color(hex: "#1c1b1f")
                                
                                HStack {
                                    Image("filter-solid")
                                        .resizable()
                                        .frame(maxWidth: 24, maxHeight: 24)
                                        .foregroundColor(Color(hex: "#ff4cb0"))
                                    
                                    Text("Filter")
                                        .foregroundColor(Color(hex: "#ff4cb0"))
                                        .font(.system(size: 18, weight: .heavy))
                                }
                                .padding(16)
                            }
                            .fixedSize()
                            .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: proxy.size.width, alignment: .trailing)
                    .padding(.bottom, 14)
                    
                    HStack {
                        Text("Search Results")
                            .font(.system(size: 20, weight: .heavy))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Button(action: {
                            resultDisplayGrid = false
                        }) {
                            Image("list")
                                .resizable()
                                .frame(maxWidth: 16, maxHeight: 16)
                                .foregroundColor(.white.opacity(!resultDisplayGrid ? 1.0 : 0.7))
                                .padding(.trailing, 12)
                        }
                        
                        Button(action: {
                            resultDisplayGrid = true
                        }) {
                            Image("grid")
                                .resizable()
                                .frame(maxWidth: 16, maxHeight: 16)
                                .foregroundColor(.white.opacity(resultDisplayGrid ? 1.0 : 0.7))
                        }
                    }
                    .padding(.bottom, 20)
                    
                    if(anilist.searchresults != nil) {
                        if(resultDisplayGrid) {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(0..<anilist.searchresults!.results.count) { index in
                                    NavigationLink(destination: Info(id: anilist.searchresults!.results[index].id)) {
                                        AnimeCard(image: anilist.searchresults!.results[index].image, rating: anilist.searchresults!.results[index].rating, title: anilist.searchresults!.results[index].title.english ?? anilist.searchresults!.results[index].title.romaji, currentEpisodeCount: anilist.searchresults!.results[index].currentEpisodeCount, totalEpisodes: anilist.searchresults!.results[index].totalEpisodes)
                                    }
                                }
                            }
                        } else {
                            ForEach(0..<anilist.searchresults!.results.count) { index in
                                NavigationLink(destination: Info(id: anilist.searchresults!.results[index].id)) {
                                    ZStack(alignment: .center) {
                                        KFImage(URL(string: anilist.searchresults!.results[index].cover ?? anilist.searchresults!.results[index].image))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: proxy.size.width - 40, height: 200)
                                            .frame(maxWidth: proxy.size.width - 40, maxHeight: 200)
                                            .cornerRadius(30)
                                        
                                        
                                        Rectangle()
                                            .fill(LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color(hex: "#001C1C1C"), location: 0.4),
                                                    .init(color: Color(hex: "#901C1C1C"), location: 0.671875),
                                                    .init(color: Color(hex: "#ff1C1C1C"), location: 0.7864583134651184)]),
                                                startPoint: UnitPoint(x: 0, y: 0),
                                                endPoint: UnitPoint(x: 0, y: 1)))
                                            .frame(width: proxy.size.width - 40, height: 200)
                                            .cornerRadius(30)
                                        
                                        HStack(alignment: .bottom) {
                                            ZStack(alignment: .bottomTrailing) {
                                                KFImage(URL(string: anilist.searchresults!.results[index].image))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 110, height: 160)
                                                    .frame(maxWidth: 110, maxHeight: 160)
                                                    .cornerRadius(12)
                                                
                                                ZStack {
                                                    Rectangle()
                                                        .foregroundColor(Color(hex: "#80ff5dae"))
                                                    
                                                    Text(anilist.searchresults!.results[index].rating != nil ? String(format: "%.1f", Float(anilist.searchresults!.results[index].rating!) / 10) : "0.0")
                                                        .font(.system(size: 12, weight: .heavy))
                                                        .padding(.vertical, 6)
                                                        .padding(.horizontal, 8)
                                                }
                                                .fixedSize()
                                                .clipShape(
                                                    RoundCorner(
                                                        cornerRadius: 30,
                                                        maskedCorners: [.topLeft]
                                                    )//OUR CUSTOM SHAPE
                                                )
                                            }
                                            .frame(maxWidth: 110, maxHeight: 160)
                                            .cornerRadius(12)
                                            .clipped()
                                            
                                            VStack {
                                                Text(anilist.searchresults!.results[index].title.romaji)
                                                    .fontWeight(.heavy)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.bottom, 6)
                                                
                                                Text(String(anilist.searchresults!.results[index].totalEpisodes ?? 0) + " Episodes")
                                                    .font(.system(size: 16))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            
                                        }
                                        .padding(.horizontal, 20)
                                        
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .adaptiveSheet(isPresented: $showingPopover, detents: [.medium()], smallestUndimmedDetentIdentifier: .large){
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .foregroundColor(
                    Color(hex: "#1c1b1f"))
                .overlay {
                    VStack(alignment: .leading) {
                        HStack {
                            Image("filter-solid")
                                .resizable()
                                .frame(maxWidth: 24, maxHeight: 24)
                                .foregroundColor(Color(hex: "#cbc4d1"))
                            
                            Text("Filter")
                                .foregroundColor(Color(hex: "#eeeeee"))
                                .font(.system(size: 18, weight: .heavy))
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 22)
                        .padding(.horizontal, 20)
                        
                        VStack {
                            HStack {
                                Menu {
                                    ForEach(0..<supportedSorting.count) {index in
                                        Button {
                                            // do something
                                            selectedSorting = supportedSorting[index]
                                            print(selectedSorting)
                                        } label: {
                                            Text(supportedSorting[index])
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text("Sort By")
                                            .foregroundColor(Color(hex: "#969295"))
                                            .font(.system(size: 16, weight: .heavy))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrowtriangle.down.fill")
                                            .resizable()
                                            .frame(maxWidth: 12, maxHeight: 6)
                                            .foregroundColor(Color(hex: "#969295"))
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                    }
                                }
                                
                                Spacer()
                                    .frame(maxWidth: 20)
                                
                                
                                Menu {
                                    ForEach(0..<supportedFormats.count) {index in
                                        Button {
                                            // do something
                                            selectedFormat = supportedFormats[index]
                                            print(selectedFormat)
                                        } label: {
                                            Text(supportedFormats[index])
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text("Format")
                                            .foregroundColor(Color(hex: "#969295"))
                                            .font(.system(size: 16, weight: .heavy))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrowtriangle.down.fill")
                                            .resizable()
                                            .frame(maxWidth: 12, maxHeight: 6)
                                            .foregroundColor(Color(hex: "#969295"))
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                            
                            HStack {
                                Menu {
                                    Button {
                                        // do something
                                        selectedSeason = "SPRING"
                                    } label: {
                                        Text("SPRING")
                                    }
                                    Button {
                                        // do something
                                        selectedSeason = "SUMMER"
                                    } label: {
                                        Text("SUMMER")
                                    }
                                    Button {
                                        // do something
                                        selectedSeason = "FALL"
                                    } label: {
                                        Text("FALL")
                                    }
                                    Button {
                                        // do something
                                        selectedSeason = "WINTER"
                                    } label: {
                                        Text("WINTER")
                                    }
                                } label: {
                                    HStack {
                                        Text("Season")
                                            .foregroundColor(Color(hex: "#969295"))
                                            .font(.system(size: 16, weight: .heavy))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrowtriangle.down.fill")
                                            .resizable()
                                            .frame(maxWidth: 12, maxHeight: 6)
                                            .foregroundColor(Color(hex: "#969295"))
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                    }
                                }
                                
                                Spacer()
                                    .frame(maxWidth: 20)
                                
                                Menu {
                                    ForEach((minYear...maxYear).reversed(), id: \.self) {index in
                                        Button {
                                            // do something
                                            selectedYear = String(index)
                                            print(selectedYear)
                                        } label: {
                                            Text(String(index))
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedYear.count > 0 ? selectedYear : "Year")
                                            .foregroundColor(Color(hex: "#969295"))
                                            .font(.system(size: 16, weight: .heavy))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrowtriangle.down.fill")
                                            .resizable()
                                            .frame(maxWidth: 12, maxHeight: 6)
                                            .foregroundColor(Color(hex: "#969295"))
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading) {
                            Text("Genres")
                                .font(.system(size: 18, weight: .heavy))
                                .padding(.leading, 12)
                                .padding(.bottom, 6)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    ForEach(0..<supportedGenres.count) {index in
                                        ZStack {
                                            Color.white.opacity(selectedGenres.contains(supportedGenres[index]) ? 1.0 : 0.0)
                                            
                                            Text(supportedGenres[index])
                                                .font(.system(size: 16, weight: .heavy))
                                                .foregroundColor(Color(hex: selectedGenres.contains(supportedGenres[index]) ? "#000000" : "#e7e1e5"))
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                        }
                                        .frame(maxHeight: 30)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                                        }
                                        .onTapGesture {
                                            if(selectedGenres.contains(supportedGenres[index])) {
                                                selectedGenres.remove(at: selectedGenres.index(of: supportedGenres[index]) ?? 0)
                                            } else {
                                                selectedGenres.append(supportedGenres[index])
                                            }
                                            print(selectedGenres)
                                        }
                                    }
                                }
                            }
                            .padding(.leading, 20)
                        }
                        .padding(.top, 12)
                        
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {}) {
                                Text("Cancel")
                                    .foregroundColor(Color(hex: "#ff4cb0"))
                                    .font(.system(size: 20, weight: .heavy))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                    }.onTapGesture {
                                        selectedYear = ""
                                        selectedGenres = []
                                        selectedFormat = ""
                                        selectedSeason = ""
                                        selectedSorting = ""
                                        showingPopover.toggle()
                                    }
                            }
                            
                            Spacer()
                                .frame(maxWidth: 20)
                            
                            
                            Button(action: {}) {
                                Text("Apply")
                                    .foregroundColor(Color(hex: "#ff4cb0"))
                                    .font(.system(size: 20, weight: .heavy))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                    }.onTapGesture {
                                        showingPopover.toggle()
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarTitle("")
        .foregroundColor(Color(hex: "#00ffffff"))
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader {proxy in
            Search(proxy: proxy)
        }
    }
}
