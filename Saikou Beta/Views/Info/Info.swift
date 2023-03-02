//
//  ContentView.swift
//  Saikou Beta
//
//  Created by Inumaki on 04.02.23.
//

import SwiftUI
import Kingfisher
import Shimmer
import ActivityIndicatorView

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct MaterialToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        
        return HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(maxWidth: 50,maxHeight: 20)
                    .foregroundColor(Color(hex: configuration.isOn ? "#543793" : "#948f9a"))
                    .animation(.spring(response: 0.3), value: configuration.isOn)
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 32,height: 32)
                    .frame(maxWidth: 32,maxHeight: 32)
                    .foregroundColor(Color(hex: configuration.isOn ? "#8aa4ff" : "#e9e9e9"))
                    .padding(.trailing, configuration.isOn ? -70 : 20)
                    .animation(.spring(response: 0.3), value: configuration.isOn)
            }.onTapGesture {
                configuration.isOn.toggle()
            }
            
            Spacer()
                .frame(maxWidth: 12)
            
            configuration.label
        }
    }
}


class Anilist : ObservableObject{
    @Published var infodata: InfoData? = nil
    @Published var searchresults: SearchResults? = nil
    @Published var episodes: [Episode]? = nil
    @Published var error: Error? = nil
    
    let baseUrl: String = "https://api.consumet.org/meta/anilist"
    
    func search(query: String, year: String, season: String, genres: [String], format: String, sort_by: String) async {
        guard let url = URL(string: "\(baseUrl)/advanced-search?query=\(query)\(year.count > 0 ? "&year=" + year : "")\(season.count > 0 ? "&season=" + season : "")\(genres.count > 0 ? "&genres=" + ("%5B%22" + genres.joined(separator: "%22%2C%22") + "%22%5D") : "")\(format.count > 0 ? "&format=" + format : "")\(sort_by.count > 0 ? "&sort=%5B%22" + sort_by + "%22%5D" : "")") else {
            print("Invalid url...")
            return
        }
        print(url)
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                self.searchresults = try JSONDecoder().decode(SearchResults.self, from: data)
            } catch let error {
                self.error = error
                print("Something went wrong.")
            }
        } catch {
            print("couldnt load data")
        }
    }
    
    func getInfo(id: String, provider: String) async {
        guard let url = URL(string: "\(baseUrl)/data/\(id)?fetchFiller=true&provider=\(provider)") else {
            print("Invalid url...")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                self.infodata = try JSONDecoder().decode(InfoData.self, from: data)
            } catch let error {
                self.error = error
                print("Something went wrong.")
            }
            
        } catch {
            print("couldnt load data")
        }
    }
    
    func getEpisodes(id: String, provider: String, dubbed: Bool) async {
        guard let url = URL(string: "\(baseUrl)/episodes/\(id)?fetchFiller=true&provider=\(provider)&dub=\(dubbed)") else {
            print("Invalid url...")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                self.episodes = try JSONDecoder().decode([Episode].self, from: data)
            } catch let error {
                self.error = error
                print("Something went wrong.")
            }
        } catch {
            print("couldnt load data")
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct Info: View {
    var id: String
    var type: String
    
    @StateObject private var viewModel = InfoViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var isOn = false
    @State var startEpisodeList = 0
    @State var endEpisodeList = 50
    @State var paginationIndex = 0
    @State var lineLimitArray: [Int] = []
    @State var episodeDisplayGrid = false
    @State private var selectedItem = 1
    @State var selectedProvider = "gogoanime"
    @State var finishedLoadingEpisodes = false
    
    let columns = [
        GridItem(.adaptive(minimum: 140), alignment: .top)
    ]
    
    var uniqueKey: String {
        UUID().uuidString
    }
    
    var options: [DropdownOption] = []
    
    init(id: String, type: String) {
        self.id = id
        self.type = type
        
        options = [
            DropdownOption(key: uniqueKey, value: "Gogo"),
            DropdownOption(key: uniqueKey, value: "Zoro"),
            DropdownOption(key: uniqueKey, value: "Animepahe"),
            DropdownOption(key: uniqueKey, value: "Animefox"),
        ]
    }
    
    @State var showHeader = false
    @State var showRealHeader = false
    @State var offset: CGFloat = 0.0
    @State var movingOffset: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color(.black)
                
                if(viewModel.infodata != nil) {
                    if(proxy.size.width < 900)  {
                        ScrollView {
                            VStack {
                                VStack {
                                    TopView(cover: viewModel.infodata!.cover, image: viewModel.infodata!.image, romajiTitle: viewModel.infodata!.title.romaji, status: viewModel.infodata!.status, width: proxy.size.width, height: 500, showHeader: showHeader, totalEpisodes: viewModel.infodata!.totalEpisodes)
                                    
                                    HStack(alignment: .top) {
                                        VStack(spacing: 12) {
                                           ExtraInfoTexts(viewModel: viewModel)
                                            
                                            VStack(alignment: .leading) {
                                                Text("Trailer")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 18, weight: .heavy))
                                                
                                                KFImage(URL(string: viewModel.infodata!.trailer != nil ? viewModel.infodata!.trailer!.thumbnail : ""))
                                                    .resizable()
                                                    .aspectRatio(16/9,contentMode: .fit)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Description")
                                                    .font(.system(size: 14, weight: .heavy))
                                                    .foregroundColor(.white)
                                                Text("    " + (try! AttributedString(markdown: viewModel.infodata!.description.replacingOccurrences(of: "_", with: "*").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "<br>", with: "\n"), options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))))
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                        .padding(.horizontal, 30)
                                        .frame(minWidth: proxy.size.width,maxWidth: proxy.size.width, maxHeight: .infinity, alignment: .top)
                                        
                                        VStack {
                                            VStack {
                                                VStack {
                                                    
                                                        Button(action: {
                                                            print("Hello button tapped!")
                                                        }) {
                                                            ZStack {
                                                                Color(hex: "#fa1852")
                                                                
                                                                HStack {
                                                                    Image(systemName: "play.circle.fill")
                                                                        .foregroundColor(.white)
                                                                        .padding(.leading, 30)
                                                                    
                                                                    Text("Play on Youtube")
                                                                        .font(.system(size: 16, weight: .semibold))
                                                                        .foregroundColor(Color.white)
                                                                        .padding(.vertical, 16)
                                                                        .frame(maxWidth: .infinity)
                                                                        .padding(.trailing, 52)
                                                                }
                                                            }
                                                            .fixedSize(horizontal: false, vertical: true)
                                                            .cornerRadius(12)
                                                        }
                                                        .padding(.horizontal, 20)
                                                        .padding(.top, 12)
                                                        
                                                        Text("Selected : \(viewModel.infodata!.title.romaji)")
                                                            .font(.system(size: 16, weight: .heavy))
                                                            .lineLimit(1)
                                                            .padding(.horizontal, 20)
                                                            .padding(.top, 20)
                                                }
                                                
                                                VStack {
                                                    DropdownSelector(
                                                        placeholder: "Gogo",
                                                        options: options,
                                                        onOptionSelected: { option in
                                                            print(option.value)
                                                            Task {
                                                                switch option.value {
                                                                case "Gogo":
                                                                    selectedProvider = "gogoanime"
                                                                case "Zoro":
                                                                    selectedProvider = "zoro"
                                                                case "Animepahe":
                                                                    selectedProvider = "animepahe"
                                                                case "Animefox":
                                                                    selectedProvider = "animefox"
                                                                default:
                                                                    selectedProvider = "gogoanime"
                                                                }
                                                                await viewModel.fetchEpisodes(id: id, provider: selectedProvider, dubbed: isOn)
                                                                self.lineLimitArray = Array(repeating: 3, count: viewModel.episodedata!.count)
                                                                viewModel.infodata!.episodes = viewModel.episodedata
                                                            }
                                                        })
                                                    .padding(.horizontal)
                                                    .zIndex(100)
                                                    
                                                    HStack {
                                                        Toggle(isOn: $isOn, label: {
                                                            Text(isOn ? "Dubbed" : "Subbed")
                                                                .font(.system(size: 18, weight: .heavy))
                                                                .foregroundColor(.white)
                                                        })
                                                        .toggleStyle(MaterialToggleStyle())
                                                        .onChange(of: isOn) { value in
                                                            Task {
                                                                await viewModel.fetchEpisodes(id: id, provider: selectedProvider, dubbed: isOn)
                                                                self.lineLimitArray = Array(repeating: 3, count: viewModel.episodedata!.count)
                                                                viewModel.infodata!.episodes = viewModel.episodedata
                                                            }
                                                        }
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.horizontal, 20)
                                                    
                                                    
                                                    HStack {
                                                        Text("Episodes")
                                                            .font(.system(size: 20, weight: .heavy))
                                                        
                                                        HStack {
                                                            Button(action: {
                                                                episodeDisplayGrid = false
                                                                print(episodeDisplayGrid)
                                                            }) {
                                                                Image("list")
                                                                    .resizable()
                                                                    .frame(maxWidth: 16, maxHeight: 16)
                                                                    .foregroundColor(.white.opacity(!episodeDisplayGrid ? 1.0 : 0.5))
                                                                    .padding(.trailing, 12)
                                                            }
                                                            
                                                            Button(action: {
                                                                episodeDisplayGrid = true
                                                                print(episodeDisplayGrid)
                                                            }) {
                                                                Image("grid")
                                                                    .resizable()
                                                                    .frame(maxWidth: 16, maxHeight: 16)
                                                                    .foregroundColor(.white.opacity(episodeDisplayGrid ? 1.0 : 0.5))
                                                            }
                                                        }
                                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                                    }
                                                    .padding(.horizontal, 20)
                                                    .padding(.top, 12)
                                                    
                                                    
                                                    if(viewModel.episodedata != nil && viewModel.episodedata!.count > 0) {
                                                        ContinueWatchingCard(image: viewModel.episodedata![0].image, title: viewModel.episodedata![0].title ?? "Title", width: proxy.size.width)
                                                        
                                                        if(viewModel.episodedata!.count > 50) {
                                                            ScrollView(.horizontal) {
                                                                HStack(spacing: 20) {
                                                                    ForEach(0..<Int(ceil(Float(viewModel.episodedata!.count)/50))) { index in
                                                                        EpisodePaginationChip(paginationIndex: paginationIndex, startEpisodeList: startEpisodeList, endEpisodeList: endEpisodeList, episodeCount: viewModel.episodedata!.count, index: index)
                                                                    }
                                                                }
                                                            }
                                                            .frame(maxWidth: proxy.size.width - 20, alignment: .leading)
                                                            .padding(.leading, 20)
                                                            .padding(.bottom, 20)
                                                        }
                                                        
                                                        if(!episodeDisplayGrid) {
                                                            
                                                            VStack {
                                                                ForEach(startEpisodeList..<min(endEpisodeList, viewModel.episodedata!.count), id: \.self) { index in
                                                                    EpisodeCard(image: viewModel.episodedata![index].image, episodeIndex: index, title: viewModel.episodedata![index].title ?? "", description: viewModel.episodedata![index].description ?? "", episodeNumber: viewModel.episodedata![index].number ?? 0, selectedProvider: selectedProvider, id: id, index: index, lineLimitArray: $lineLimitArray, viewModel: viewModel, type: .LIST)
                                                                }
                                                                .padding(.horizontal, 20)
                                                            }
                                                        } else {
                                                            LazyVGrid(columns: columns, spacing: 20) {
                                                                ForEach(startEpisodeList..<min(endEpisodeList, viewModel.episodedata!.count), id: \.self) { index in
                                                                    EpisodeCard(image: viewModel.episodedata![index].image, episodeIndex: index, title: viewModel.episodedata![index].title ?? "", description: viewModel.episodedata![index].description ?? "", episodeNumber: viewModel.episodedata![index].number ?? 0, selectedProvider: selectedProvider, id: id, index: index, lineLimitArray: $lineLimitArray, viewModel: viewModel, type: .GRID)
                                                                }
                                                            }
                                                            .padding(.horizontal, 20)
                                                        }
                                                    }
                                                    else {
                                                        ProgressView()
                                                    }
                                                }
                                            }
                                        }
                                        .frame(minWidth: proxy.size.width,maxWidth: proxy.size.width)
                                    }
                                    .frame(minWidth: proxy.size.width,maxWidth: proxy.size.width)
                                    .offset(x: selectedItem == 0 ? (proxy.size.width / 2) : -(proxy.size.width / 2))
                                    .animation(movingOffset != 0 ? .linear : .easeInOut)
                                    .padding(.bottom, 80)
                                }
                            }
                            .background(GeometryReader {
                                Color.clear.preference(key: ViewOffsetKey.self,
                                                       value: -$0.frame(in: .named("scroll")).origin.y)
                            })
                            .onPreferenceChange(ViewOffsetKey.self) {
                                //print("offset >> \($0)")
                                if($0 >= 150 && $0 < 380) {
                                    showHeader = true
                                    showRealHeader = false
                                } else if($0 >= 380) {
                                    showHeader = true
                                    showRealHeader = true
                                } else {
                                    showHeader = false
                                    showRealHeader = false
                                }
                            }
                        }
                        .coordinateSpace(name: "scroll")
                    } else {
                        HStack {
                            ScrollView {
                                VStack {
                                    TopView(cover: viewModel.infodata!.cover, image: viewModel.infodata!.image, romajiTitle: viewModel.infodata!.title.romaji, status: viewModel.infodata!.status, width: proxy.size.width * 0.68, height: 300, showHeader: false, totalEpisodes: viewModel.infodata!.totalEpisodes)
                                    
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading) {
                                            Button(action: {
                                                print("Hello button tapped!")
                                            }) {
                                                Text("ADD TO LIST")
                                                    .font(.system(size: 16, weight: .heavy))
                                                    .foregroundColor(Color(hex: "#8ca7ff"))
                                                    .padding(.vertical, 16)
                                                    .frame(maxWidth: .infinity)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                                    )
                                            }
                                            
                                            ExtraInfoTexts(viewModel: viewModel)
                                        }
                                        .padding(.horizontal, 20)
                                        .frame(width: proxy.size.width * 0.34)
                                        .frame(maxWidth: proxy.size.width * 0.34, alignment: .top)
                                        
                                        VStack(alignment: .leading) {
                                            Text("Trailer")
                                                .foregroundColor(.white)
                                                .font(.system(size: 18, weight: .heavy))
                                            
                                            KFImage(URL(string: viewModel.infodata!.trailer != nil ? viewModel.infodata!.trailer!.thumbnail : ""))
                                                .resizable()
                                                .aspectRatio(16/9,contentMode: .fit)
                                                .frame(maxWidth: proxy.size.width * 0.34)
                                        }
                                        .padding(.horizontal, 20)
                                        .frame(width: proxy.size.width * 0.34)
                                        .frame(maxWidth: proxy.size.width * 0.34, alignment: .top)
                                    }
                                    .frame(maxWidth: proxy.size.width * 0.68, alignment: .top)
                                    .padding(.top, 18)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Description")
                                            .font(.system(size: 14, weight: .heavy))
                                            .foregroundColor(.white)
                                        Text("    " + (try! AttributedString(markdown: viewModel.infodata!.description.replacingOccurrences(of: "_", with: "*").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "<br>", with: "\n"), options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: proxy.size.width * 0.68)
                                    .padding(.top, 20)
                                }
                            }
                            .frame(width: proxy.size.width * 0.68)
                            .frame(maxWidth: proxy.size.width * 0.68)
                            .clipShape(
                                RoundCorner(
                                    cornerRadius: 20,
                                    maskedCorners: [.topRight]
                                )
                            )
                            ScrollView {
                                VStack {
                                    DropdownSelector(
                                        placeholder: "Gogo",
                                        options: options,
                                        onOptionSelected: { option in
                                            print(option.value)
                                            Task {
                                                switch option.value {
                                                case "Gogo":
                                                    selectedProvider = "gogoanime"
                                                case "Zoro":
                                                    selectedProvider = "zoro"
                                                case "Animepahe":
                                                    selectedProvider = "animepahe"
                                                case "Animefox":
                                                    selectedProvider = "animefox"
                                                default:
                                                    selectedProvider = "gogoanime"
                                                }
                                                await viewModel.fetchEpisodes(id: id, provider: selectedProvider, dubbed: isOn)
                                                self.lineLimitArray = Array(repeating: 3, count: viewModel.episodedata!.count)
                                                viewModel.infodata!.episodes = viewModel.episodedata
                                            }
                                        })
                                    .padding(.horizontal)
                                    .zIndex(100)
                                    .padding(.top, 30)
                                    
                                    HStack {
                                        Toggle(isOn: $isOn, label: {
                                            Text(isOn ? "Dubbed" : "Subbed")
                                                .font(.system(size: 18, weight: .heavy))
                                                .foregroundColor(.white)
                                        })
                                        .toggleStyle(MaterialToggleStyle())
                                        .onChange(of: isOn) { value in
                                            Task {
                                                await viewModel.fetchEpisodes(id: id, provider: selectedProvider, dubbed: isOn)
                                                if(viewModel.episodedata != nil) {
                                                    self.lineLimitArray = Array(repeating: 3, count: viewModel.episodedata!.count)
                                                }
                                                viewModel.infodata!.episodes = viewModel.episodedata
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                    
                                    
                                    HStack {
                                        Text("Episodes")
                                            .font(.system(size: 20, weight: .heavy))
                                        
                                        HStack {
                                            Button(action: {
                                                episodeDisplayGrid = false
                                                print(episodeDisplayGrid)
                                            }) {
                                                Image("list")
                                                    .resizable()
                                                    .frame(maxWidth: 16, maxHeight: 16)
                                                    .foregroundColor(.white.opacity(!episodeDisplayGrid ? 1.0 : 0.5))
                                                    .padding(.trailing, 12)
                                            }
                                            
                                            Button(action: {
                                                episodeDisplayGrid = true
                                                print(episodeDisplayGrid)
                                            }) {
                                                Image("grid")
                                                    .resizable()
                                                    .frame(maxWidth: 16, maxHeight: 16)
                                                    .foregroundColor(.white.opacity(episodeDisplayGrid ? 1.0 : 0.5))
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 12)
                                    
                                    
                                    if(viewModel.episodedata != nil) {
                                        ContinueWatchingCard(image: viewModel.episodedata![0].image, title: viewModel.episodedata![0].title ?? "Title", width: proxy.size.width)
                                        
                                        if(viewModel.episodedata!.count > 50) {
                                            ScrollView(.horizontal) {
                                                HStack(spacing: 20) {
                                                    ForEach(0..<Int(ceil(Float(viewModel.episodedata!.count)/50))) { index in
                                                        EpisodePaginationChip(paginationIndex: paginationIndex, startEpisodeList: startEpisodeList, endEpisodeList: endEpisodeList, episodeCount: viewModel.episodedata!.count, index: index)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: proxy.size.width - 20, alignment: .leading)
                                            .padding(.leading, 20)
                                            .padding(.bottom, 20)
                                        }
                                        
                                        if(!episodeDisplayGrid) {
                                            
                                            VStack {
                                                ForEach(startEpisodeList..<min(endEpisodeList, viewModel.episodedata!.count), id: \.self) { index in
                                                    EpisodeCard(image: viewModel.episodedata![index].image, episodeIndex: index, title: viewModel.episodedata![index].title ?? "", description: viewModel.episodedata![index].description ?? "", episodeNumber: viewModel.episodedata![index].number ?? 0, selectedProvider: selectedProvider, id: id, index: index, lineLimitArray: $lineLimitArray, viewModel: viewModel, type: .LIST)
                                                }
                                                .padding(.horizontal, 20)
                                            }
                                        } else {
                                            LazyVGrid(columns: columns, spacing: 20) {
                                                ForEach(startEpisodeList..<min(endEpisodeList, viewModel.episodedata!.count), id: \.self) { index in
                                                    EpisodeCard(image: viewModel.episodedata![index].image, episodeIndex: index, title: viewModel.episodedata![index].title ?? "", description: viewModel.episodedata![index].description ?? "", episodeNumber: viewModel.episodedata![index].number ?? 0, selectedProvider: selectedProvider, id: id, index: index, lineLimitArray: $lineLimitArray, viewModel: viewModel, type: .GRID)
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                        }
                                    }
                                    else {
                                        ProgressView()
                                    }
                                }
                            }
                        }
                    }
                } else if( viewModel.mangaInfodata != nil) {
                    ScrollView {
                        VStack {
                            VStack {
                                TopView(cover: viewModel.mangaInfodata!.cover, image: viewModel.mangaInfodata!.image, romajiTitle: viewModel.mangaInfodata!.title.romaji, status: viewModel.mangaInfodata!.status, width: proxy.size.width, height: 500, showHeader: showHeader, totalEpisodes: viewModel.mangaInfodata!.totalEpisodes)
                                
                                VStack {
                                    VStack {
                                        Button(action: {
                                            print("Hello button tapped!")
                                        }) {
                                            ZStack {
                                                Color(hex: "#fa1852")
                                                
                                                HStack {
                                                    Image(systemName: "play.circle.fill")
                                                        .foregroundColor(.white)
                                                        .padding(.leading, 30)
                                                    
                                                    Text("Play on Youtube")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(Color.white)
                                                        .padding(.vertical, 16)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.trailing, 52)
                                                }
                                            }
                                            .cornerRadius(12)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 12)
                                        
                                        Text("Selected : \(viewModel.mangaInfodata!.title.romaji)")
                                            .font(.system(size: 16, weight: .heavy))
                                            .lineLimit(1)
                                            .padding(.horizontal, 20)
                                            .padding(.top, 20)
                                        
                                        VStack {
                                            HStack {
                                                Text("Chapters")
                                                    .font(.system(size: 20, weight: .heavy))
                                                
                                                HStack {
                                                    Button(action: {
                                                        episodeDisplayGrid = false
                                                        print(episodeDisplayGrid)
                                                    }) {
                                                        Image("list")
                                                            .resizable()
                                                            .frame(maxWidth: 16, maxHeight: 16)
                                                            .foregroundColor(.white.opacity(!episodeDisplayGrid ? 1.0 : 0.5))
                                                            .padding(.trailing, 12)
                                                    }
                                                    
                                                    Button(action: {
                                                        episodeDisplayGrid = true
                                                        print(episodeDisplayGrid)
                                                    }) {
                                                        Image("grid")
                                                            .resizable()
                                                            .frame(maxWidth: 16, maxHeight: 16)
                                                            .foregroundColor(.white.opacity(episodeDisplayGrid ? 1.0 : 0.5))
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.top, 12)
                                            
                                            
                                            if(viewModel.chapterdata != nil && viewModel.chapterdata!.count > 0) {
                                                ContinueWatchingCard(image: viewModel.mangaInfodata!.cover, title: viewModel.chapterdata![0].title ?? "Title", width: proxy.size.width)
                                                
                                                if(viewModel.chapterdata!.count > 50) {
                                                    ScrollView(.horizontal) {
                                                        HStack(spacing: 20) {
                                                            ForEach(0..<Int(ceil(Float(viewModel.chapterdata!.count)/50))) { index in
                                                                EpisodePaginationChip(paginationIndex: paginationIndex, startEpisodeList: startEpisodeList, endEpisodeList: endEpisodeList, episodeCount: viewModel.chapterdata!.count, index: index)
                                                            }
                                                        }
                                                    }
                                                    .frame(maxWidth: proxy.size.width - 20, alignment: .leading)
                                                    .padding(.leading, 20)
                                                    .padding(.bottom, 20)
                                                }
                                                
                                                VStack {
                                                    ForEach(startEpisodeList..<min(endEpisodeList, viewModel.chapterdata!.count), id: \.self) { index in
                                                        NavigationLink(destination: Reader(mangaData: viewModel.mangaInfodata, selectedChapterIndex: index)) {
                                                            ZStack(alignment: .leading) {
                                                                Color(hex: "#282828")
                                                                
                                                                Text(viewModel.chapterdata![index].title ?? "Chapter \(index + 1)")
                                                                    .font(.system(size: 18, weight: .heavy))
                                                                    .foregroundColor(.white)
                                                                    .padding(20)
                                                            }
                                                            .cornerRadius(20)
                                                            .frame(maxWidth: proxy.size.width - 40)
                                                        }
                                                    }
                                                    .padding(.horizontal, 20)
                                                }
                                            }
                                            else {
                                                ProgressView()
                                            }
                                        }
                                    }
                                }
                                .tag(1)
                                .padding(.bottom, 80)
                            }
                        }
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                                   value: -$0.frame(in: .named("scroll")).origin.y)
                        })
                        .onPreferenceChange(ViewOffsetKey.self) {
                            //print("offset >> \($0)")
                            if($0 >= 150 && $0 < 380) {
                                showHeader = true
                                showRealHeader = false
                            } else if($0 >= 380) {
                                showHeader = true
                                showRealHeader = true
                            } else {
                                showHeader = false
                                showRealHeader = false
                            }
                        }
                    }
                    .coordinateSpace(name: "scroll")
                } else {
                    ScrollView {
                        VStack {
                            ZStack(alignment: .bottom) {
                                Rectangle()
                                    .foregroundColor(Color(hex: "#444444"))
                                    .frame(width: proxy.size.width, height: 420)
                                    .frame(maxWidth: proxy.size.width, maxHeight: 420)
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                                
                                
                                Rectangle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)), location: 0),
                                            .init(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), location: 1)]),
                                        startPoint: UnitPoint(x: 0.5, y: -3.0616171314629196e-17),
                                        endPoint: UnitPoint(x: 0.5, y: 0.9999999999999999)))
                                    .frame(width: proxy.size.width, height: 420)
                                    .frame(maxWidth: proxy.size.width,maxHeight: 420)
                                
                                
                                HStack(alignment: .bottom) {
                                    Rectangle()
                                        .foregroundColor(Color(hex: "#444444"))
                                        .frame(maxWidth: 120, maxHeight: 180)
                                        .cornerRadius(18)
                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                    
                                    Spacer()
                                        .frame(maxWidth: 20)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Youkoso Jitsuryoku Shijou Shugi no Kyoushitsu e")
                                            .font(.system(size: 18, weight: .heavy))
                                            .lineSpacing(8.0)
                                            .redacted(reason: .placeholder)
                                            .shimmering()
                                        
                                        Spacer()
                                            .frame(maxHeight: 20)
                                        
                                        Text("FINISHED")
                                            .font(.system(size: 16, weight: .heavy))
                                            .foregroundColor(Color(hex: "#c23d81"))
                                            .redacted(reason: .placeholder)
                                            .shimmering()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 20)
                            }
                            
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
                                
                                Text("12")
                                    .padding(.leading, -8)
                                    .font(.system(size: 16, weight: .heavy))
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            
                            Button(action: {
                                print("Hello button tapped!")
                            }) {
                                ZStack {
                                    Color(hex: "#fa1852")
                                    
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                            .foregroundColor(.white)
                                            .padding(.leading, 30)
                                        
                                        Text("Play on Youtube")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.white)
                                            .padding(.vertical, 16)
                                            .frame(maxWidth: .infinity)
                                            .padding(.trailing, 52)
                                    }
                                }
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            
                            Text("Selected : Youkoso Jitsuryoku Shijou Shugi no Kyoushitsu e")
                                .font(.system(size: 16, weight: .heavy))
                                .lineLimit(1)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .redacted(reason: .placeholder)
                                .shimmering()
                            
                            Menu {
                                Button {
                                    // do something
                                } label: {
                                    Text("Linear")
                                    Image(systemName: "arrow.down.right.circle")
                                }
                                Button {
                                    // do something
                                } label: {
                                    Text("Radial")
                                    Image(systemName: "arrow.up.and.down.circle")
                                }
                            } label: {
                                ZStack {
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(Color(hex: "#8b8789"))
                                            .frame(width: 26)
                                            .padding(.leading, 20)
                                            .padding(.trailing, 12)
                                        
                                        Text("GOGO")
                                            .font(.system(size: 18, weight: .heavy))
                                            .foregroundColor(Color(hex: "#cbc4d1"))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(Color(hex: "#8b8789"))
                                            .frame(width: 16)
                                            .padding(.trailing, 20)
                                    }
                                    .frame(height: 58)
                                    .frame(maxWidth: .infinity, maxHeight: 58)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                    )
                                    
                                    ZStack {
                                        Color(.black)
                                        
                                        Text("Source")
                                            .font(.system(size: 14, weight: .heavy))
                                            .foregroundColor(Color(hex: "#8b8789"))
                                            .padding(.horizontal, 6)
                                    }
                                    .fixedSize()
                                    .padding(.trailing, 260)
                                    .padding(.bottom, 58)
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            HStack {
                                Toggle(isOn: $isOn, label: {
                                    Text("Subbed")
                                        .font(.system(size: 18, weight: .heavy))
                                        .foregroundColor(.white)
                                })
                                .toggleStyle(MaterialToggleStyle())
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            
                            HStack {
                                Text("Episodes")
                                    .font(.system(size: 20, weight: .heavy))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(Color(hex: "#444444"))
                                        .frame(maxHeight: 160)
                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                    
                                    Rectangle()
                                        .foregroundColor(.black.opacity(0.6))
                                    
                                    HStack {
                                        Text("Continue : Episode 1\nWhat is evil? Whatever springs from weakness.")
                                            .lineLimit(2)
                                            .lineSpacing(8.0)
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: 16, weight: .heavy))
                                            .redacted(reason: .placeholder)
                                            .shimmering()
                                        
                                        Spacer()
                                            .frame(maxWidth: 20)
                                        
                                        Image(systemName: "play.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 24)
                                    }
                                    .padding(.horizontal, 20)
                                    
                                }
                                .frame(maxHeight: 160)
                                .cornerRadius(20)
                                .clipped()
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                
                                ForEach(0..<6) { index in
                                    ZStack(alignment: .topLeading) {
                                        Color(hex: "#282828")
                                        
                                        VStack {
                                            HStack {
                                                Rectangle()
                                                    .foregroundColor(Color(hex: "#444444"))
                                                    .frame(maxWidth: 170)
                                                    .aspectRatio(16/9, contentMode: .fit)
                                                    .cornerRadius(12)
                                                    .redacted(reason: .placeholder)
                                                    .shimmering()
                                                
                                                Text("What is evil? Whatever springs from weakness.")
                                                    .font(.system(size: 14, weight: .heavy))
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.trailing, 20)
                                                    .redacted(reason: .placeholder)
                                                    .shimmering()
                                            }
                                            
                                            Text("Kiyotaka Ayanokoji begins attending school in class 1-D at the Tokyo Metropolitan Advanced Nurturing High School, an institution established by the government for training Japan's best students. Class D homeroom teacher Sae Chabashira explains the point system where everybody gets a monthly allowance 100,000 points that they can use as money at local shops with one point equaling one yen, and also warns the students that they are judged on merit. Ayanokoji begins navigating through the system being careful about how he spends his points, while becoming friends with the gregarious Kikyo Kushida and then attempting to become friends with the aloof outsider Suzune Horikita. In an attempt to become friends, Ayanokoji brings Suzune to a cafe where only girls meet having secretly arranged for Kushida and two other classmates to be there, but Suzune saw through the plan and leaves without becoming friends. As the month of April passes, the majority of class D lavishly spends their points and slacks off in class without any reprimand, causing Ayanokoji to be suspicious. On May 1, the class D students are surprised to find out that they did not get an allowance, and Chabashira explains that their allowance depends on merit and having ignored their studies, the class receives no points for the month.")
                                                .lineLimit(3)
                                                .foregroundColor(.white.opacity(0.7))
                                                .font(.system(size: 14, weight: .semibold))
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .padding(.bottom, 8)
                                                .redacted(reason: .placeholder)
                                                .shimmering()
                                        }
                                        
                                        ZStack {
                                            Color(.white)
                                            
                                            Text("\(index + 1)")
                                                .foregroundColor(.black)
                                                .font(.system(size: 24, weight: .heavy))
                                                .padding(6)
                                        }
                                        .fixedSize()
                                        .clipShape(
                                            RoundCorner(
                                                cornerRadius: 30,
                                                maskedCorners: [.bottomRight]
                                            )//OUR CUSTOM SHAPE
                                        )
                                    }
                                    .cornerRadius(12)
                                    .padding(.bottom, 8)
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 80)
                        }
                    }
                }
                
                
                
                VStack {
                    ZStack(alignment: .bottom) {
                        if(viewModel.infodata != nil) {
                            ZStack(alignment: .bottom) {
                                Color(hex: "#1c1c1c")
                                HStack {
                                    Text(viewModel.infodata!.title.romaji)
                                        .lineLimit(1)
                                        .font(.system(size: 20, weight: .heavy))
                                        .padding(.leading, 20)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                            .opacity(showRealHeader ? 1.0 : 0.0)
                        } else if(viewModel.mangaInfodata != nil) {
                            ZStack(alignment: .bottom) {
                                Color(hex: "#1c1c1c")
                                HStack {
                                    Text(viewModel.mangaInfodata!.title.romaji)
                                        .lineLimit(1)
                                        .font(.system(size: 20, weight: .heavy))
                                        .padding(.leading, 20)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                            .opacity(showRealHeader ? 1.0 : 0.0)
                        }
                        
                        HStack {
                            Button(
                                action: { self.presentationMode.wrappedValue.dismiss() }
                            ) {
                                ZStack {
                                    Color.white
                                    
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(8)
                                }
                                .fixedSize()
                                .cornerRadius(40)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(maxHeight: 120)
                    
                    Spacer()
                    
                    if(proxy.size.width < 900) {
                        ZStack {
                            Color(hex: "#1c1c1c")
                            HStack(alignment: .top) {
                                Spacer()
                                VStack {
                                    ZStack {
                                        Color(hex: selectedItem == 0 ? "#ff8ca7ff" :  "#008ca7ff")
                                            .animation(.spring())
                                        
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(selectedItem == 0 ? .black : .white.opacity(0.5))
                                            .font(.system(size: 22))
                                            .padding(.horizontal, 22)
                                            .padding(.vertical, 6)
                                    }
                                    .fixedSize()
                                    .cornerRadius(30)
                                    
                                    Text("INFO")
                                        .fontWeight(.heavy)
                                        .foregroundColor(selectedItem == 0 ? .white : .white.opacity(0.5))
                                }
                                .padding(.bottom, 4)
                                .onTapGesture {
                                    selectedItem = 0
                                }
                                Spacer()
                                VStack {
                                    ZStack {
                                        Color(hex: selectedItem == 1 ? "#ff8ca7ff" :  "#008ca7ff")
                                            .animation(.spring())
                                        
                                        Image("clapperboard-play")
                                            .resizable()
                                            .foregroundColor(selectedItem == 1 ? .black : .white.opacity(0.5))
                                            .frame(width: 22, height: 22)
                                            .frame(maxWidth: 22, maxHeight: 22)
                                            .padding(.horizontal, 22)
                                            .padding(.vertical, 8)
                                    }
                                    .fixedSize()
                                    .cornerRadius(30)
                                    
                                    Text("WATCH")
                                        .fontWeight(.heavy)
                                        .foregroundColor(selectedItem == 1 ? .white : .white.opacity(0.5))
                                }
                                .onTapGesture {
                                    selectedItem = 1
                                }
                                Spacer()
                            }
                            .padding(.bottom, 16)
                            
                        }
                        .frame(maxHeight: 110)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            .onAppear{
                Task {
                    if(type == "anime") {
                        viewModel.onAppear(id: id, provider: "gogoanime", type: type)
                        finishedLoadingEpisodes = false
                        await viewModel.fetchEpisodes(id: id, provider: "gogoanime", dubbed: isOn)
                        if(viewModel.episodedata != nil) {
                            self.lineLimitArray = Array(repeating: 3, count: viewModel.episodedata!.count)
                            finishedLoadingEpisodes = true
                        }
                    } else {
                        viewModel.onAppear(id: id, provider: "mangadex", type: type)
                        finishedLoadingEpisodes = false
                        //await viewModel.fetchChapters(id: id, provider: "mangadex")
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Info(id: "98659", type: "anime")
    }
}
