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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

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

struct InfoData: Codable {
    let id: String
    let title: Title
    let malId: Int?
    let synonyms: [String]?
    let isLicensed, isAdult: Bool?
    let countryOfOrigin: String?
    let trailer: Trailer?
    let image: String
    let popularity: Int
    let color: String?
    let cover: String
    let description, status: String
    let releaseDate: Int
    let startDate: Date
    let endDate: Date?
    let nextAiringEpisode: AiringData?
    let totalEpisodes: Int?
    let currentEpisodeCount: Int?
    let duration: Int?
    let rating: Int?
    let genres: [String]
    let season: String?
    let studios: [String]
    let subOrDub: String?
    let type: String?
    let recommendations: [Recommended]?
    let characters: [Character]
    let relations: [Related]?
    var episodes: [Episode]?
}

struct AnilistInfo: Codable {
    let id: String
    let title: Title
    let malId: Int?
    let synonyms: [String]?
    let isLicensed, isAdult: Bool?
    let countryOfOrigin: String?
    let trailer: Trailer?
    let image: String
    let popularity: Int
    let color: String?
    let cover: String
    let description, status: String
    let releaseDate: Int
    let startDate: Date
    let endDate: Date?
    let nextAiringEpisode: AiringData?
    let totalEpisodes: Int?
    let currentEpisodeCount: Int?
    let duration: Int?
    let rating: Int?
    let genres: [String]
    let season: String?
    let studios: [String]
    let subOrDub: String?
    let type: String?
    let recommendations: [Recommended]?
    let characters: [Character]
    let relations: [Related]?
    var episodes: [Episode]?
}

struct Title: Codable, Hashable {
    let romaji: String
    var english: String?
    let native: String?
    var userPreferred: String?
}

struct Date: Codable {
    let year: Int?
    let month: Int?
    let day: Int?
}

struct AiringData: Codable {
    let airingTime: Int
    let timeUntilAiring: Int
    let episode: Int
}

struct Trailer: Codable {
    let id, site: String
    let thumbnail: String
}

struct Episode: Codable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let number: Int?
    let image: String
    let isFiller: Bool?
}

struct Character: Codable {
    let id: Int?
    let role: String
    let name: Name
    let image: String
    let voiceActors: [VoiceActor]?
}

struct Name: Codable {
    let first, last, full: String?
    let native: String?
    let userPreferred: String
}

struct VoiceActor: Codable {
    let id: Int
    let name: Name
    let image: String
}

struct Related: Codable {
    let id: Int?
    let relationType: String
    let malId: Int?
    let title: Title
    let status: String
    var episodes: Int?
    let image: String
    let color, type: String?
    let cover: String
    let rating: Int?
}

struct Recommended: Codable {
    let id: Int?
    let malId: Int?
    let title: Title
    let status: String
    let episodes: Int?
    let image, cover: String
    let rating: Int?
    let type: String?
}

struct SearchResults: Codable {
    let currentPage: Int
    let hasNextPage: Bool
    let results: [SearchData]
}

struct SearchData: Codable {
    let id: String
    let malId: Int?
    let title: Title
    let status: String
    let image: String
    let cover: String?
    let popularity: Int
    let description: String?
    let rating: Int?
    let genres: [String]
    let color: String?
    let totalEpisodes: Int?
    let currentEpisodeCount: Int?
    let type: String?
    let releaseDate: Int?
}

class Anilist : ObservableObject{
    @Published var infodata: InfoData? = nil
    @Published var searchresults: SearchResults? = nil
    @Published var episodes: [Episode]? = nil
    
    let baseUrl: String = "https://api.consumet.org/meta/anilist"
    
    func search(query: String, year: String, season: String, genres: [String], format: String, sort_by: String) async {
        guard let url = URL(string: "\(baseUrl)/advanced-search?query=\(query)\(year.count > 0 ? "&year=" + year : "")\(season.count > 0 ? "&season=" + season : "")\(genres.count > 0 ? "&genres=" + ("%5B%22" + genres.joined(separator: "%22%2C%22") + "%22%5D") : "")\(format.count > 0 ? "&format=" + format : "")\(sort_by.count > 0 ? "&sort=%5B%22" + sort_by + "%22%5D" : "")") else {
            print("Invalid url...")
            return
        }
        print(url)
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.searchresults = try! JSONDecoder().decode(SearchResults.self, from: data)
            
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
            self.infodata = try! JSONDecoder().decode(InfoData.self, from: data)
            
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
            self.episodes = try! JSONDecoder().decode([Episode].self, from: data)
            
        } catch {
            print("couldnt load data")
        }
    }
}

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

struct DropdownOption: Hashable {
    let key: String
    let value: String
    
    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }
}

struct DropdownSelector: View {
    @State private var shouldShowDropdown = false
    @State private var selectedOption: DropdownOption? = nil
    var placeholder: String
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    private let buttonHeight: CGFloat = 58
    
    var body: some View {
        Button(action: {
            self.shouldShowDropdown.toggle()
        }) {
            ZStack {
                HStack {
                    Image(systemName: "folder.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(hex: "#8b8789"))
                        .frame(width: 26)
                        .padding(.leading, 10)
                        .padding(.trailing, 12)
                    
                    Text(selectedOption == nil ? placeholder : selectedOption!.value)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color(hex: "#cbc4d1"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(hex: "#8b8789"))
                        .frame(width: 16)
                        .padding(.trailing, 10)
                }
                .frame(height: 58)
                .frame(maxWidth: .infinity, maxHeight: 58)
                
                
            }
        }
        .padding(.horizontal)
        .cornerRadius(5)
        .frame(width: .infinity, height: self.buttonHeight)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .overlay {
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
        .overlay(
            VStack {
                if self.shouldShowDropdown {
                    Spacer(minLength: buttonHeight + 10)
                    Dropdown(options: self.options, onOptionSelected: { option in
                        shouldShowDropdown = false
                        selectedOption = option
                        self.onOptionSelected?(option)
                    })
                }
            }
            , alignment: .topLeading
        )
    }
}

struct Dropdown: View {
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.options, id: \.self) { option in
                    DropdownRow(option: option, onOptionSelected: self.onOptionSelected)
                }
            }
        }
        .frame(height: CGFloat(options.count) * 50 + 10)
        .frame(minHeight: CGFloat(options.count) * 50 + 10, maxHeight: 500)
        .padding(.vertical, 5)
        .background(Color(hex: "#1c1b1f"))
        .cornerRadius(5)
    }
}

struct DropdownRow: View {
    var option: DropdownOption
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    
    var body: some View {
        Button(action: {
            if let onOptionSelected = self.onOptionSelected {
                onOptionSelected(self.option)
            }
        }) {
            HStack {
                Text(self.option.value)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(Color(hex: "#cbc4d1"))
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

struct Info: View {
    var id: String
    @State private var isOn = false
    @StateObject var anilist: Anilist = Anilist()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var startEpisodeList = 0
    @State var endEpisodeList = 50
    @State var paginationIndex = 0
    @State private var lineLimitArray: [Int] = []
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
    
    init(id: String) {
        self.id = id
        
        options = [
            DropdownOption(key: uniqueKey, value: "Gogo"),
            DropdownOption(key: uniqueKey, value: "Zoro"),
            DropdownOption(key: uniqueKey, value: "Animepahe"),
        ]
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color(.black)
                
                if(anilist.infodata != nil) {
                    ScrollView {
                        VStack {
                            VStack {
                                TopView(anilist: anilist, proxy: proxy)
                                
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
                                    
                                    Text(String(anilist.infodata!.totalEpisodes ?? 0))
                                        .padding(.leading, -8)
                                        .font(.system(size: 16, weight: .heavy))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                                
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
                                        
                                        Text("Selected : \(anilist.infodata!.title.romaji)")
                                            .font(.system(size: 16, weight: .heavy))
                                            .lineLimit(1)
                                            .padding(.horizontal, 20)
                                            .padding(.top, 20)
                                        
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
                                                        default:
                                                            selectedProvider = "gogoanime"
                                                        }
                                                        await anilist.getEpisodes(id: id, provider: selectedProvider, dubbed: isOn)
                                                        self.lineLimitArray = Array(repeating: 3, count: anilist.episodes!.count)
                                                        anilist.infodata!.episodes = anilist.episodes
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
                                                        await anilist.getEpisodes(id: id, provider: selectedProvider, dubbed: value)
                                                        self.lineLimitArray = Array(repeating: 3, count: anilist.episodes!.count)
                                                        anilist.infodata!.episodes = anilist.episodes
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
                                            
                                            
                                            if(anilist.episodes != nil) {
                                                ZStack {
                                                    KFImage(URL(string: anilist.episodes![0].image))
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(maxWidth: proxy.size.width - 40,maxHeight: 100)
                                                        .contentShape(Rectangle().path(in: CGRect(x: 0, y: 0, width: 0, height: 0)))
                                                    
                                                    Rectangle()
                                                        .foregroundColor(.black.opacity(0.6))
                                                    
                                                    HStack {
                                                        Text("Continue : Episode 1\n\(anilist.episodes![0].title ?? "Title")")
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
                                                
                                                if(anilist.episodes!.count > 50) {
                                                    ScrollView(.horizontal) {
                                                        HStack(spacing: 20) {
                                                            ForEach(0..<Int(ceil(Float(anilist.episodes!.count)/50))) { index in
                                                                ZStack {
                                                                    Color(hex: index == paginationIndex ? "#8ca7ff" : "#1c1b1f")
                                                                    
                                                                    
                                                                    Text("\((50 * index) + 1) - " + String(50 + (50 * index) > anilist.episodes!.count ? anilist.episodes!.count : 50 + (50 * index)))
                                                                        .font(.system(size: 16, weight: .heavy))
                                                                        .padding(.vertical, 6)
                                                                        .padding(.horizontal, 12)
                                                                }
                                                                .fixedSize()
                                                                .cornerRadius(6)
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 6)
                                                                        .stroke(Color.white.opacity(0.7), lineWidth: index == paginationIndex ? 0 : 1)
                                                                )
                                                                .onTapGesture {
                                                                    startEpisodeList = 50 * index
                                                                    endEpisodeList = 50 + (50 * index) > anilist.episodes!.count ? anilist.episodes!.count : 50 + (50 * index)
                                                                    paginationIndex = index
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .frame(maxWidth: proxy.size.width - 20, alignment: .leading)
                                                    .padding(.leading, 20)
                                                    .padding(.bottom, 20)
                                                }
                                                
                                                if(!episodeDisplayGrid) {
                                                    
                                                    VStack {
                                                        ForEach(startEpisodeList..<min(endEpisodeList, anilist.episodes!.count), id: \.self) { index in
                                                            ZStack(alignment: .topLeading) {
                                                                Color(hex: "#282828")
                                                                
                                                                VStack {
                                                                    NavigationLink(destination: WatchPage(aniData: anilist.infodata!, episodeIndex: index, anilistId: id, provider: selectedProvider)) {
                                                                        HStack {
                                                                            KFImage(URL(string: anilist.episodes![index].image))
                                                                                .resizable()
                                                                                .aspectRatio(contentMode: .fit)
                                                                                .frame(maxWidth: 170)
                                                                                .cornerRadius(12)
                                                                            
                                                                            Text(anilist.episodes![index].title ?? "Episode \(index + 1)")
                                                                                .font(.system(size: 14, weight: .heavy))
                                                                                .frame(maxWidth: .infinity)
                                                                                .padding(.trailing, 20)
                                                                                .lineLimit(4)
                                                                                .foregroundColor(.white)
                                                                        }
                                                                    }
                                                                    
                                                                    Text(anilist.episodes![index].description ?? "Description")
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
                                                                    
                                                                    Text(String(anilist.episodes![index].number ?? 0))
                                                                        .foregroundColor(.black)
                                                                        .font(.system(size: 24, weight: .heavy))
                                                                        .padding(6)
                                                                }
                                                                .fixedSize()
                                                                .cornerRadius(30, corners: [.bottomRight])
                                                            }
                                                            .cornerRadius(12)
                                                            .padding(.bottom, 8)
                                                        }
                                                        .padding(.horizontal, 20)
                                                    }
                                                } else {
                                                    LazyVGrid(columns: columns, spacing: 20) {
                                                        ForEach(startEpisodeList..<min(endEpisodeList, anilist.episodes!.count), id: \.self) { index in
                                                            NavigationLink(destination: WatchPage(aniData: anilist.infodata!, episodeIndex: index, anilistId: id, provider: selectedProvider)) {
                                                                ZStack {
                                                                    KFImage(URL(string: anilist.episodes![index].image))
                                                                        .resizable()
                                                                        .aspectRatio(contentMode: .fill)
                                                                        .frame(maxWidth: 170, maxHeight: 120)
                                                                        .cornerRadius(20)
                                                                    
                                                                    Rectangle()
                                                                        .frame(maxWidth: 170, maxHeight: 120)
                                                                        .cornerRadius(20)
                                                                        .foregroundColor(.black.opacity(0.6))
                                                                    
                                                                    ZStack(alignment: .topLeading) {
                                                                        Text(anilist.episodes![index].title ?? "Title")
                                                                            .font(.system(size: 16, weight: .heavy))
                                                                            .lineLimit(3)
                                                                            .multilineTextAlignment(.leading)
                                                                            .padding(.horizontal, 20)
                                                                            .padding(.top, -40)
                                                                            .frame(width: 170, height: 120)
                                                                            .frame(maxWidth: 170, maxHeight: 120, alignment: .topLeading)
                                                                        
                                                                        Text(String(anilist.episodes![index].number ?? 0))
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
                                                    .padding(.horizontal, 20)
                                                }
                                            }
                                        }
                                    }
                                }
                                .tag(1)
                                .padding(.bottom, 80)
                            }
                        }
                    }
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
                                        .cornerRadius(30, corners: [.bottomRight])
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
                    .padding(.top, 70)
                    
                    Spacer()
                    
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            .onAppear{
                Task {
                    await anilist.getInfo(id: id, provider: "gogoanime")
                    print("Done with Init.")
                    finishedLoadingEpisodes = false
                    await anilist.getEpisodes(id: id, provider: "gogoanime", dubbed: isOn)
                    self.lineLimitArray = Array(repeating: 3, count: anilist.episodes!.count)
                    anilist.infodata!.episodes = anilist.episodes
                    finishedLoadingEpisodes = true
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
        Info(id: "98659")
    }
}

struct TopView: View {
    let anilist: Anilist
    let proxy: GeometryProxy
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { reader in
                FillAspectImage(
                    url: URL(string: anilist.infodata!.cover)
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
                .frame(width: proxy.size.width, height: 420)
                .frame(maxWidth: proxy.size.width,maxHeight: 420)
            
            HStack(alignment: .bottom) {
                KFImage(URL(string: anilist.infodata!.image))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 120, maxHeight: 180)
                    .cornerRadius(18)
                
                Spacer()
                    .frame(maxWidth: 20)
                
                VStack(alignment: .leading) {
                    Text(anilist.infodata!.title.romaji)
                        .font(.system(size: 18, weight: .heavy))
                        .lineSpacing(8.0)
                    
                    Spacer()
                        .frame(maxHeight: 20)
                    
                    Text(anilist.infodata!.status)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(Color(hex: "#c23d81"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 420)
    }
}
