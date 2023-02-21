//
//  WatchPage.swift
//  Inus Stream
//
//  Created by Inumaki on 26.09.22.
//
import SwiftUI
import AVKit
import SwiftUIFontIcon

import Combine
import SwiftWebVTT
import ActivityIndicatorView

extension AnyTransition {
    static var backslide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .trailing))}
}

class StreamApi : ObservableObject{
    @Published var streamdata: StreamData? = nil
    
    func loadStream(id: String, provider: String) async {
        guard let url = URL(string: "https://api.consumet.org/meta/anilist/watch/\(id)?provider=\(provider)") else {
            print("Invalid url...")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.streamdata = try! JSONDecoder().decode(StreamData.self, from: data)
        } catch {
            print("couldnt load data")
        }
        
    }
}

struct GaugeProgressStyle: ProgressViewStyle {
    var strokeColor = Color.white
    var strokeWidth = 12.0
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        
        return ZStack {
            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

struct WatchPage: View {
    var animeData: InfoData?
    let episodeIndex: Int
    let anilistId: String?
    var provider: String?
    var episodedata: [Episode]
    @Environment(\.presentationMode) var presentation
    @StateObject var infoApi = Anilist()
    @State private var isPresented = false
    
    init(aniData: InfoData?, episodeIndex: Int, anilistId: String?, provider: String?, episodedata: [Episode]) {
        animeData = aniData
        self.episodeIndex = episodeIndex
        self.anilistId = anilistId
        self.provider = provider
        self.episodedata = episodedata
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            
            return ZStack {
                CustomPlayerWithControls(animeData: animeData, episodeIndex: episodeIndex, provider: provider, episodedata: episodedata)
                    .navigationBarBackButtonHidden(true)
                    .contentShape(Rectangle())
                    .ignoresSafeArea(.all)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all)
            .edgesIgnoringSafeArea(.all)
            .supportedOrientation(.landscape)
            .prefersHomeIndicatorAutoHidden(true)
        } else {
            return CustomPlayerWithControls(animeData: animeData!, episodeIndex: episodeIndex, provider: provider, episodedata: episodedata)
                .contentShape(Rectangle())
                .ignoresSafeArea(.all)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .supportedOrientation(.landscape)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct WatchPage_Previews: PreviewProvider {
    static var previews: some View {
        WatchPage(aniData: InfoData(id: "98659",
                                    title: Title(
                                        romaji: "Youkoso Jitsuryoku Shijou Shugi no Kyoushitsu e",
                                        english: "Classroom of the Elite",
                                        native: "ようこそ実力至上主義の教室へ"
                                        
                                    ),
                                    malId: 35507,
                                    synonyms: [
                                        "Youjitsu",
                                        "You-Zitsu",
                                        "ขอต้อนรับสู่ห้องเรียนนิยม (เฉพาะ) ยอดคน",
                                        "Cote",
                                        "歡迎來到實力至上主義的教室"
                                    ],
                                    isLicensed: true,
                                    isAdult: false,
                                    countryOfOrigin: "JP",
                                    trailer: nil,
                                    image: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/b98659-sH5z5RfMuyMr.png",
                                    popularity: 224139,
                                    color: "#43a135",
                                    cover: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/98659-u46B5RCNl9il.jpg",
                                    description: "Koudo Ikusei Senior High School is a leading school with state-of-the-art facilities. The students there have the freedom to wear any hairstyle and bring any personal effects they desire. Koudo Ikusei is like a utopia, but the truth is that only the most superior students receive favorable treatment.<br><br>\n\nKiyotaka Ayanokouji is a student of D-class, which is where the school dumps its \"inferior\" students in order to ridicule them. For a certain reason, Kiyotaka was careless on his entrance examination, and was put in D-class. After meeting Suzune Horikita and Kikyou Kushida, two other students in his class, Kiyotaka's situation begins to change. <br><br>\n(Source: Anime News Network, edited)",
                                    status: "Completed",
                                    releaseDate: 2017,
                                    startDate: Date(
                                        year: 2017,
                                        month: 7,
                                        day: 12
                                    ),
                                    endDate: Date(
                                        year: 2017,
                                        month: 9,
                                        day: 27
                                    ),
                                    nextAiringEpisode: nil,
                                    totalEpisodes: 12,
                                    currentEpisodeCount: 12,
                                    duration: 24,
                                    rating: 77,
                                    genres: [
                                        "Drama",
                                        "Psychological"
                                    ],
                                    season: "SUMMER",
                                    studios: [
                                        "Lerche"
                                    ],
                                    subOrDub: "sub",
                                    type: "TV",
                                    recommendations: nil,
                                    characters: [],
                                    relations: nil,
                                    episodes: [
                                        Episode(id: "classroom-of-the-elite-713$episode$12865",
                                                title: "What is evil? Whatever springs from weakness.",
                                                description: "Kiyotaka Ayanokoji begins attending school in class 1-D at the Tokyo Metropolitan Advanced Nurturing High School, an institution established by the government for training Japan's best students. Class D homeroom teacher Sae Chabashira explains the point system where everybody gets a monthly allowance 100,000 points that they can use as money at local shops with one point equaling one yen, and also warns the students that they are judged on merit. Ayanokoji begins navigating through the system being careful about how he spends his points, while becoming friends with the gregarious Kikyo Kushida and then attempting to become friends with the aloof outsider Suzune Horikita. In an attempt to become friends, Ayanokoji brings Suzune to a cafe where only girls meet having secretly arranged for Kushida and two other classmates to be there, but Suzune saw through the plan and leaves without becoming friends. As the month of April passes, the majority of class D lavishly spends their points and slacks off in class without any reprimand, causing Ayanokoji to be suspicious. On May 1, the class D students are surprised to find out that they did not get an allowance, and Chabashira explains that their allowance depends on merit and having ignored their studies, the class receives no points for the month.",
                                                number: 1,
                                                image: "https://artworks.thetvdb.com/banners/episodes/329822/6125438.jpg", isFiller: false
                                               )
                                    ]
                                   ), episodeIndex: 0, anilistId: "98659", provider: "gogoanime", episodedata: [])
    }
}

struct CustomView: View {
    
    @Binding var percentage: Double // or some value binded
    @Binding var isDragging: Bool
    @State var barHeight: CGFloat = 6
    
    var total: Double
    
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .bottomLeading) {
                
                Rectangle()
                    .foregroundColor(.white.opacity(0.5)).frame(height: barHeight, alignment: .bottom).cornerRadius(12)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onEnded({ value in
                            self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                            self.isDragging = false
                            self.barHeight = 6
                        })
                            .onChanged({ value in
                                self.isDragging = true
                                self.barHeight = 10
                                print(value)
                                // TODO: - maybe use other logic here
                                self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                            })).animation(.spring(response: 0.3), value: self.isDragging)
                Rectangle()
                    .foregroundColor(Color(hex: "#ff91A6FF"))
                    .frame(width: geometry.size.width * CGFloat(self.percentage / total)).frame(height: barHeight, alignment: .bottom).cornerRadius(12)
                
                
            }.frame(maxHeight: .infinity, alignment: .center)
                .cornerRadius(12)
                .gesture(DragGesture(minimumDistance: 0)
                    .onEnded({ value in
                        self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                        self.isDragging = false
                        self.barHeight = 6
                    })
                        .onChanged({ value in
                            self.isDragging = true
                            self.barHeight = 10
                            print(value)
                            // TODO: - maybe use other logic here
                            self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                        })).animation(.spring(response: 0.3), value: self.isDragging)
            
        }
    }
}

struct VolumeView: View {
    
    @State var percentage: Float // or some value binded
    @Binding var isDragging: Bool
    @State var barWidth: CGFloat = 6
    @State var playerVM: PlayerViewModel
    
    var total: Double
    
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .bottomLeading) {
                
                Rectangle()
                    .foregroundColor(.white.opacity(0.5)).frame(width: barWidth, alignment: .bottom).cornerRadius(12)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onEnded({ value in
                            self.percentage = Float(min(max(0, Double(value.location.y / geometry.size.height * total)), total))
                            self.isDragging = false
                            self.barWidth = 6
                            
                            playerVM.setVolume(newVolume: self.percentage)
                            
                        })
                            .onChanged({ value in
                                self.isDragging = true
                                self.barWidth = 10
                                print(value)
                                // TODO: - maybe use other logic here
                                self.percentage = Float(min(max(0, Double(value.location.y / geometry.size.height * total)), total))
                                
                                playerVM.setVolume(newVolume: self.percentage)
                                
                            })).animation(.spring(response: 0.3), value: self.isDragging)
                Rectangle()
                    .foregroundColor(.white)
                    .frame(height: geometry.size.height * CGFloat(Double(self.percentage) / total)).frame(width: barWidth, alignment: .bottom).cornerRadius(12)
                
                
            }.frame(maxHeight: .infinity, alignment: .center)
                .cornerRadius(12)
                .gesture(DragGesture(minimumDistance: 0)
                    .onEnded({ value in
                        self.percentage = Float(min(max(0, Double(value.location.y / geometry.size.height * total)), total))
                        self.isDragging = false
                        self.barWidth = 6
                        
                        playerVM.setVolume(newVolume: self.percentage)
                        
                    })
                        .onChanged({ value in
                            self.isDragging = true
                            self.barWidth = 10
                            print(value)
                            // TODO: - maybe use other logic here
                            self.percentage = Float(min(max(0, Double(value.location.y / geometry.size.height * total)), total))
                            playerVM.setVolume(newVolume: self.percentage)
                            
                        })).animation(.spring(response: 0.3), value: self.isDragging)
            
        }
    }
}
