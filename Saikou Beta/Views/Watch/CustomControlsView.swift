//
//  CustomControlsView.swift
//  Saikou Beta
//
//  Created by Inumaki on 20.02.23.
//

import SwiftUI
import AVKit
import SwiftUIFontIcon
import SwiftWebVTT
import ActivityIndicatorView
import Kingfisher

struct GradientStop: Equatable {
    var color: Color
    var location: Double
}

extension GradientStop: VectorArithmetic {
    static var zero: GradientStop {
        GradientStop(color: .clear, location: 0)
    }
    
    static func + (lhs: GradientStop, rhs: GradientStop) -> GradientStop {
        GradientStop(color: lhs.color, location: lhs.location + rhs.location)
    }
    
    static func - (lhs: GradientStop, rhs: GradientStop) -> GradientStop {
        GradientStop(color: lhs.color, location: lhs.location - rhs.location)
    }
    
    mutating func scale(by rhs: Double) {
        location *= rhs
    }
    
    var magnitudeSquared: Double {
        location * location
    }
}

struct CustomControlsView: View {
    @State var episodeData: StreamData?
    let animeData: InfoData
    var provider: String?
    var episodedata: [Episode]
    var viewModel: WatchViewModel
    @State var qualityIndex: Int = 0
    @State var selectedSubtitleIndex: Int = 0
    @Binding var showUI: Bool
    @State var episodeIndex: Int
    @ObservedObject var playerVM: PlayerViewModel
    @State var progress = 0.25
    @State var isLoading: Bool = false
    @State var showEpisodeSelector: Bool = false
    @StateObject var streamApi = StreamApi()
    @State var volumeDrag: Bool = false
    @State var showSubs: Bool = true
    @State var providerName = "Gogo"
    
    @State var providerOld = "gogoanime" // or gogoanime
    @State var showingPopup = false
    @State var showingEpisodeSelector = false
    @State var selectedSetting: SettingsNames = SettingsNames.home
    @State var rotation: Double = 0.0
    @State var subtitleStyle: SubtitleStyle = SubtitleStyle.Outlined
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    func secondsToMinutesSeconds(_ seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        let minuteString = (minutes < 10 ? "0" : "") +  "\(minutes)"
        let secondsString = (seconds < 10 ? "0" : "") +  "\(seconds)"
        
        return minuteString + ":" + secondsString
    }
    
    func getSettingName() -> String {
        switch selectedSetting {
        case SettingsNames.subtitle:
            return "Subtitles"
        case SettingsNames.quality:
            return "Quality"
        case SettingsNames.provider:
            return "Provider"
        case SettingsNames.sub_style:
            return "Sub Style"
        default:
            return "Settings"
        }
    }
    
    var foreverAnimation: Animation {
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        }
    
    @State private var buttonOffset: Double = -156
    @State private var textWidth: Double = 0
    @State private var skipPercentage: CGFloat = 0.0
    @State var selectedEpisode: Int = 0
    @State var startEpisodeList = 0
    @State var endEpisodeList = 50
    @State var paginationIndex = 0
    @State var animateBackward: Bool = false
    @State var animateForward: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(showUI ? 0.7 : 0.0)
            
            ZStack(alignment: .bottom) {
                if(showSubs) {
                    VStack {
                        Spacer()
                        
                        ForEach(0..<playerVM.currentSubs.count, id:\.self) {index in
                            ZStack {
                                Color(.black).opacity(0.8)
                                
                                Text(LocalizedStringKey(playerVM.currentSubs[index].text.replacingOccurrences(of: "*", with: "**").replacingOccurrences(of: "_", with: "*")))
                                    .font(.system(size: 18))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                            }
                            .fixedSize()
                            .cornerRadius(6)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 40)
            
            ZStack(alignment: .bottomTrailing) {
                HStack {
                    Color.clear
                        .frame(width: .infinity, height: 300)
                        .contentShape(Rectangle())
                        .gesture(
                            TapGesture(count: 2)
                                .onEnded({ playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime - 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)})
                                .exclusively(before:
                                    TapGesture()
                                    .onEnded({showUI = false})
                            )
                        )
                    
                    Color.clear
                        .frame(width: .infinity, height: 300)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showUI = false
                        }
                    
                    Color.clear
                        .frame(width: .infinity, height: 300)
                        .contentShape(Rectangle())
                        .gesture(
                            TapGesture(count: 2)
                                .onEnded({ playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime + 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)})
                                .exclusively(before:
                                    TapGesture()
                                    .onEnded({showUI = false})
                            )
                        )
                    
                }
                
                if viewModel.skiptimes != nil && viewModel.skiptimes!.results != nil {
                    Button(action: {
                        playerVM.isEditingCurrentTime = true
                        playerVM.currentTime = viewModel.getEndTime(type: "op")
                        playerVM.isEditingCurrentTime = false
                    }) {
                            ZStack {
                                Rectangle()
                                    .fill(.black.opacity(0.4))
                                
                                Rectangle()
                                    .fill(.white)
                                    .offset(x: buttonOffset)
                                    .onReceive(playerVM.$currentTime) { currentTime in
                                        viewModel.showSkipButton(currentTime: currentTime)
                                        let skipPercentage = viewModel.getSkipPercentage(currentTime: currentTime)
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            buttonOffset = -textWidth + (textWidth * skipPercentage)
                                        }
                                    }
                                    
                                
                                Text("Skip Opening")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(.white)
                                    .blendMode(BlendMode.difference)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 24)
                                    .overlay(
                                        GeometryReader { geometry in
                                            Color.clear
                                                .onAppear {
                                                    self.textWidth = geometry.size.width
                                                    buttonOffset = -textWidth
                                                }
                                        }
                                    )
                                
                            }
                            .fixedSize()
                            .cornerRadius(12)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
                            )
                    }
                    .padding(.bottom, 110)
                    .padding(.trailing, 4)
                    .opacity(viewModel.skipTypeText == "Opening" ? 1.0 : 0.0)
                }
                
                VStack {
                    Spacer()
                        .frame(maxHeight: 12)
                    HStack {
                        
                        // self.presentationMode.wrappedValue.dismiss()
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        })
                        
                        Spacer()
                            .frame(maxWidth: 12)
                        
                        if(episodedata != nil) {
                            VStack {
                                Text("\(String(episodedata[episodeIndex].number ?? 0)): \(episodedata[episodeIndex].title ?? "")")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(animeData.title.romaji)")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 14))
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Spacer()
                        
                        VStack {
                            Text(provider ?? "Gogo")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                                    .bold()
                                    .frame(maxWidth: 120, alignment: .trailing)
                            
                            Text(playerVM.getCurrentItem() != nil ? String(Int(playerVM.getCurrentItem()!.presentationSize.width)) + "x" + String(Int(playerVM.getCurrentItem()!.presentationSize.height)) : "unknown")
                                .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(maxWidth: 120, alignment: .trailing)
                        }
                        .frame(maxWidth: 120, alignment: .trailing)
                    }
                    Spacer()
                    HStack {
                        
                        if(playerVM.isLoading == false) {
                            Spacer()
                            ZStack {
                                Text("10")
                                    .font(.system(size: 10, weight: .bold))
                                
                                Image("goBackward")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.white.opacity(1.0))
                                    .rotationEffect(animateBackward ? Angle(degrees: -30) : .zero)
                                    .animation(.spring(response: 0.3), value: animateBackward)
                                    .onTapGesture {
                                        Task {
                                            await playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime - 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                                            // add crunchy animation
                                            animateBackward = true
                                            try? await Task.sleep(nanoseconds: 400_000_000)
                                            animateBackward = false
                                        }
                                    }
                                
                                Text("-10")
                                    .font(.system(size: 18, weight: .semibold))
                                    .offset(x: animateBackward ? -40 : 0)
                                    .opacity(animateBackward ? 1.0 : 0.0)
                                    .animation(.spring(response: 0.3), value: animateBackward)
                            }
                            
                            Spacer().frame(maxWidth: 72)
                            
                            if playerVM.isPlaying == false {
                                FontIcon.button(.awesome5Solid(code: .play), action: {
                                    
                                    playerVM.player.play()
                                }, fontsize: 42)
                                .foregroundColor(.white)
                            } else {
                                Button(action: {
                                    playerVM.player.pause()
                                }) {
                                    Image("pause")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 42, height: 50)
                                        .frame(maxWidth: 42, maxHeight: 50)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer().frame(maxWidth: 72)
                            
                            ZStack {
                                Text("10")
                                    .font(.system(size: 10, weight: .bold))
                                
                                Image("goForward")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.white.opacity(1.0))
                                    .rotationEffect(animateForward ? Angle(degrees: 30) : .zero)
                                    .animation(.spring(response: 0.3), value: animateForward)
                                    .onTapGesture {
                                        Task {
                                            await playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime + 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                                            // add crunchy animation
                                            animateForward = true
                                            try? await Task.sleep(nanoseconds: 400_000_000)
                                            animateForward = false
                                        }
                                    }
                                
                                Text("+10")
                                    .font(.system(size: 18, weight: .semibold))
                                    .offset(x: animateForward ? 40 : 0)
                                    .opacity(animateForward ? 1.0 : 0.0)
                                    .animation(.spring(response: 0.3), value: animateForward)
                            }
                            
                            Spacer()
                            
                        }
                        else {
                            ZStack {
                                if(playerVM.hasError == false) {
                                    ActivityIndicatorView(isVisible: $playerVM.isLoading, type: .growingArc(.white, lineWidth: 4))
                                        .frame(maxWidth: 40, maxHeight: 40)
                                } else {
                                    HStack {
                                        
                                        ZStack {
                                            Color(hex: "#ffFFE0E4")
                                            
                                            FontIcon.button(.awesome5Solid(code: .exclamation_triangle), action: {
                                                
                                            }, fontsize: 32)
                                            .foregroundColor(Color(hex: "#ffDE2627"))
                                            .padding(.bottom, 4)
                                        }
                                        .frame(maxWidth: 62, maxHeight: 62)
                                        .cornerRadius(31)
                                        
                                        VStack(alignment: .leading) {
                                            Text("Video Loading failed")
                                                .foregroundColor(.white)
                                                .bold()
                                                .font(.title)
                                                .padding(.leading, 4)
                                            
                                            Text("There was an error fetching the video file. Please try again later.")
                                                .foregroundColor(.white.opacity(0.7))
                                                .bold()
                                                .font(.subheadline)
                                                .frame(maxWidth: 280)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 60)
                    Spacer()
                    VStack {
                        HStack {
                            if(playerVM.duration != nil) {
                                Text("\(secondsToMinutesSeconds(Int(playerVM.currentTime))) / \(secondsToMinutesSeconds(Int(playerVM.duration!)))")
                                    .font(.system(size: 14))
                                    .bold()
                                    .foregroundColor(.white)
                            } else {
                                Text("--:-- / --:--")
                                    .font(.system(size: 14))
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            HStack {
                                
                                Image("episodes")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 24)
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        Task {
                                            showingEpisodeSelector.toggle()
                                        }
                                    }
                                
                                Spacer()
                                    .frame(maxWidth: 34)
                                
                                ZStack {
                                    FontIcon.button(.awesome5Solid(code: .cog), action: {
                                        Task {
                                            showingPopup.toggle()
                                        }
                                        
                                    }, fontsize: 20)
                                    .foregroundColor(.white)
                                }
                                
                                Spacer()
                                    .frame(maxWidth: 34)
                                
                                FontIcon.button(.awesome5Solid(code: .step_forward), action: {
                                    Task {
                                        self.episodeIndex = self.episodeIndex + 1
                                        await self.streamApi.loadStream(id: self.episodedata[episodeIndex].id, provider: provider ?? "gogoanime")
                                        playerVM.setCurrentItem(AVPlayerItem(url: URL(string:  self.streamApi.streamdata?.sources![0].url ?? "/")!))
                                        playerVM.player.play()
                                    }
                                    
                                }, fontsize: 20)
                                .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, -4)
                        
                        if(playerVM.duration != nil) {
                            CustomView(percentage: $playerVM.currentTime, isDragging: $playerVM.isEditingCurrentTime, total: playerVM.duration!)
                                .frame(height: 20)
                                .frame(maxHeight: 20)
                                .padding(.bottom, playerVM.isEditingCurrentTime ? 3 : 0 )
                        } else {
                            CustomView(percentage: Binding.constant(0.0), isDragging: Binding.constant(false), total: 1.0)
                                .frame(height: 6)
                                .frame(maxHeight: 20)
                                .padding(.bottom, 0)
                        }
                    }
                    .padding()
                    .padding(.bottom, 24)
                    .popup(isPresented: $showingPopup, isHorizontal: false) { // 3
                        ZStack { // 4
                            Color(hex: "#ff16151A")
                            VStack(alignment: .center) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(maxWidth: 110, maxHeight: 4)
                                    .foregroundColor(.white)
                                
                                if(selectedSetting != SettingsNames.home) {
                                    HStack {
                                        if(selectedSetting != SettingsNames.home) {
                                            FontIcon.button(.awesome5Solid(code: .chevron_left), action: {
                                                Task {
                                                    selectedSetting = SettingsNames.home
                                                }
                                                
                                            }, fontsize: 14)
                                            .foregroundColor(.white)
                                        }
                                        
                                        Text("\(getSettingName())")
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                if(selectedSetting == SettingsNames.home) {
                                    SettingsOption(setting_name: "Video", selected_option: episodeData?.subtitles?[playerVM.selectedSubtitleIndex].lang ?? "NaN")
                                        .frame(maxWidth: 500)
                                        .onTapGesture {
                                            selectedSetting = SettingsNames.subtitle
                                        }
                                    
                                    SettingsOption(setting_name: "Subtitles", selected_option: subtitleStyle.rawValue)
                                        .onTapGesture {
                                            selectedSetting = SettingsNames.sub_style
                                        }
                                    
                                    SettingsOption(setting_name: "Audio", selected_option: episodeData?.sources?[qualityIndex].quality ?? "NaN")
                                        .onTapGesture {
                                            selectedSetting = SettingsNames.quality
                                        }
                                    
                                    SettingsOption(setting_name: "General", selected_option: provider ?? "gogoanime")
                                        .onTapGesture {
                                            selectedSetting = SettingsNames.provider
                                        }
                                    
                                    
                                } else if(selectedSetting == SettingsNames.subtitle) {
                                ScrollView {
                                    VStack {
                                        if(episodeData != nil && episodeData!.subtitles != nil) {
                                            ForEach(0..<(episodeData!.subtitles!.count - 1)) {index in
                                                ZStack {
                                                    if(playerVM.selectedSubtitleIndex == index) {
                                                        Color(hex: "#ff464E6C")
                                                    }
                                                    
                                                    Text("\(episodeData!.subtitles![index].lang)")
                                                        .fontWeight(.medium)
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                        .frame(width: 170, height: 32, alignment: .leading)
                                                        .padding(.leading, 14)
                                                }
                                                .frame(width: 170, height: 32)
                                                .frame(maxWidth: 170, maxHeight: 32)
                                                .cornerRadius(8)
                                                .onTapGesture(perform: {
                                                    Task {
                                                        var content: String
                                                        if let url = URL(string: episodeData!.subtitles![index].url) {
                                                            do {
                                                                content = try String(contentsOf: url)
                                                                //print(content)
                                                            } catch {
                                                                // contents could not be loaded
                                                                content = ""
                                                            }
                                                        } else {
                                                            // the URL was bad!
                                                            content = ""
                                                        }
                                                        
                                                            let parser = WebVTTParser(string: content.replacingOccurrences(of: "<i>", with: "_").replacingOccurrences(of: "</i>", with: "_").replacingOccurrences(of: "<b>", with: "*").replacingOccurrences(of: "</b>", with: "*"))
                                                        let webVTT = try? parser.parse()
                                                        
                                                        playerVM.webVTT = webVTT
                                                        playerVM.selectedSubtitleIndex = index
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                                .frame(maxHeight: 200)
                                .transition(.backslide)
                                
                            }
                                else if(selectedSetting == SettingsNames.sub_style) {
                                VStack {
                                    if(episodeData != nil && episodeData!.sources != nil) {
                                        ForEach(0..<2) { index in
                                            ZStack {
                                                if(subtitleStyle == SubtitleStyle.allCases[index]) {
                                                    Color(hex: "#ff464E6C")
                                                    
                                                }
                                                
                                                Text("\(SubtitleStyle.allCases[index].rawValue)")
                                                    .fontWeight(.medium)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                    .frame(width: 170, height: 32, alignment: .leading)
                                                    .padding(.leading, 14)
                                            }
                                            .frame(width: 170, height: 32)
                                            .frame(maxWidth: 170, maxHeight: 32)
                                            .cornerRadius(8)
                                            .onTapGesture(perform: {
                                                Task {
                                                    subtitleStyle = SubtitleStyle.allCases[index]
                                                }
                                                
                                            })
                                        }
                                    }
                                }
                                .transition(.backslide)
                            }
                                else if(selectedSetting == SettingsNames.quality) {
                                    VStack {
                                        if(episodeData != nil && episodeData!.sources != nil) {
                                            ForEach(0..<(episodeData!.sources!.count - 1)) { index in
                                                ZStack {
                                                    if(index == qualityIndex) {
                                                        Color(hex: "#ff464E6C")
                                                        
                                                    }
                                                    
                                                    Text("\(episodeData!.sources![index].quality!)")
                                                        .fontWeight(.medium)
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                        .frame(width: 170, height: 32, alignment: .leading)
                                                        .padding(.leading, 14)
                                                }
                                                .frame(width: 170, height: 32)
                                                .frame(maxWidth: 170, maxHeight: 32)
                                                .cornerRadius(8)
                                                .onTapGesture(perform: {
                                                    Task {
                                                        let curTime = playerVM.currentTime
                                                        self.qualityIndex = index
                                                        await self.streamApi.loadStream(id: self.episodedata[episodeIndex].id, provider: provider ?? "gogoanime")
                                                        playerVM.setCurrentItem(AVPlayerItem(url: URL(string:  self.streamApi.streamdata?.sources![self.qualityIndex].url ?? "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!))
                                                        await playerVM.player.seek(to: CMTime(seconds: curTime, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                                                        playerVM.player.play()
                                                    }
                                                    
                                                })
                                            }
                                        }
                                    }
                                    .transition(.backslide)
                                }
                                else if(selectedSetting == SettingsNames.provider) {
                                    VStack {
                                        ZStack {
                                            if(provider == "zoro") {
                                                Color(hex: "#ff464E6C")
                                            }
                                            
                                            Text("zoro")
                                                .fontWeight(.medium)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .frame(width: 170, height: 32, alignment: .leading)
                                                .padding(.leading, 14)
                                        }
                                        .frame(width: 170, height: 32)
                                        .frame(maxWidth: 170, maxHeight: 32)
                                        .cornerRadius(8)
                                        .onTapGesture(perform: {
                                            Task {
                                                let infoApi = Anilist()
                                                
                                                await infoApi.getInfo(id: playerVM.id, provider: provider ?? "gogoanime")
                                                
                                                let ep_id = infoApi.infodata!.episodes![playerVM.episodeNumber].id
                                                
                                                await streamApi.loadStream(id: ep_id, provider: provider ?? "gogoanime")
                                                
                                                let tempTime = playerVM.currentTime
                                                
                                                episodeData = streamApi.streamdata!
                                                
                                                if(episodeData?.subtitles != nil) {
                                                    var content: String
                                                    var index = 0
                                                    
                                                    for sub in 0..<episodeData!.subtitles!.count {
                                                        if(episodeData!.subtitles![sub].lang == "English") {
                                                            index = sub
                                                        }
                                                    }
                                                    
                                                    playerVM.selectedSubtitleIndex = index
                                                    
                                                    if let url = URL(string: episodeData!.subtitles![index].url) {
                                                        do {
                                                            content = try String(contentsOf: url)
                                                            //print(content)
                                                        } catch {
                                                            // contents could not be loaded
                                                            content = ""
                                                        }
                                                    } else {
                                                        // the URL was bad!
                                                        content = ""
                                                    }
                                                    
                                                    let parser = WebVTTParser(string: content.replacingOccurrences(of: "<i>", with: "_").replacingOccurrences(of: "</i>", with: "_").replacingOccurrences(of: "<b>", with: "*").replacingOccurrences(of: "</b>", with: "*"))
                                                    let webVTT = try? parser.parse()
                                                    
                                                    playerVM.webVTT = webVTT
                                                }
                                                
                                                playerVM.setCurrentItem(AVPlayerItem(url: URL(string:  self.streamApi.streamdata?.sources?[0].url ?? "/")!))
                                                await playerVM.player.seek(to: CMTime(seconds: tempTime, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                                            }
                                        })
                                        
                                        ZStack {
                                            if(provider == "gogoanime") {
                                                Color(hex: "#ff464E6C")
                                            }
                                            
                                            Text("gogoanime")
                                                .fontWeight(.medium)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .frame(width: 170, height: 32, alignment: .leading)
                                                .padding(.leading, 14)
                                        }
                                        .frame(width: 170, height: 32)
                                        .frame(maxWidth: 170, maxHeight: 32)
                                        .cornerRadius(8)
                                        .onTapGesture(perform: {
                                            Task {
                                                await streamApi.loadStream(id: playerVM.id, provider: provider ?? "gogoanime")
                                                
                                                let tempTime = playerVM.currentTime
                                                
                                                playerVM.setCurrentItem(AVPlayerItem(url: URL(string:  self.streamApi.streamdata?.sources?[0].url ?? "/")!))
                                                playerVM.player.play()
                                                await playerVM.player.seek(to: CMTime(seconds: tempTime, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                                            }
                                        })
                                    }
                                    .transition(.backslide)
                                }
                            }
                            .padding(12)
                            .animation(.spring(response: 0.3), value: selectedSetting)
                        }
                        .frame(maxWidth: 520,maxHeight: 360, alignment: .top)
                        .ignoresSafeArea()
                        .clipShape(
                            RoundCorner(
                                cornerRadius: 20,
                                maskedCorners: [.topLeft, .topRight]
                            )//OUR CUSTOM SHAPE
                        )
                        .padding(.bottom, -120)
                        .zIndex(100)
                    }
                    .popup(isPresented: $showingEpisodeSelector, isHorizontal: true) {
                        ZStack(alignment: .leading) {
                            Color(hex: "#ff1C1C1C")
                            HStack(spacing: 0) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.white)
                                        .frame(maxWidth: 3, maxHeight: 90)
                                }
                                .frame(maxWidth: 20, maxHeight: .infinity)
                                ScrollView {
                                    VStack {
                                        ForEach(startEpisodeList..<min(endEpisodeList, episodedata.count), id: \.self) { index in
                                            ZStack {
                                                Color(hex: "#282828")
                                                VStack(alignment: .leading) {
                                                    HStack(spacing: 6) {
                                                        KFImage(URL(string: episodedata[index].image))
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .cornerRadius(8)
                                                            .clipped()
                                                            .frame(width: 130, height: 130 / 16 * 9)
                                                            .frame(maxWidth: 180, maxHeight: 100)
                                                        
                                                        Text(episodedata[index].title ?? "Episode")
                                                            .font(.system(size: 12, weight: .heavy))
                                                            .lineLimit(3)
                                                            .padding(.trailing, 8)
                                                            .multilineTextAlignment(.leading)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, -14)
                                                    
                                                    if (selectedEpisode == index) {
                                                        Text(episodedata[index].description ?? "Description")
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.white.opacity(0.7))
                                                            .padding(12)
                                                            .padding(.top, -12)
                                                            .lineLimit(4)
                                                    }
                                                }
                                                .animation(.spring(response: 0.3))
                                            }
                                            .cornerRadius(14)
                                            .clipped()
                                            .padding(.trailing, 12)
                                            .onTapGesture {
                                                if(selectedEpisode == index) {
                                                    if(index != self.episodeIndex){
                                                        Task {
                                                            self.episodeIndex = index
                                                            await self.streamApi.loadStream(id: self.episodedata[episodeIndex].id, provider: provider ?? "gogoanime")
                                                            playerVM.setCurrentItem(AVPlayerItem(url: URL(string:  self.streamApi.streamdata?.sources![0].url ?? "/")!))
                                                            playerVM.player.play()
                                                        }
                                                    }
                                                } else {
                                                    selectedEpisode = index
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 20)
                                .padding(.bottom, episodedata.count > 50 ? 60 : 0)
                            }
                            VStack {
                                Spacer()
                                if(episodedata.count > 50) {
                                    ZStack {
                                        Color(.black)
                                        
                                        ScrollView(.horizontal) {
                                            HStack(spacing: 20) {
                                                ForEach(0..<Int(ceil(Float(episodedata.count)/50))) { index in
                                                    ZStack {
                                                        Color(hex: index == paginationIndex ? "#8ca7ff" : "#1c1b1f")
                                                        
                                                        
                                                        Text("\((50 * index) + 1) - " + String(50 + (50 * index) > episodedata.count ? episodedata.count : 50 + (50 * index)))
                                                            .font(.system(size: 12, weight: .heavy))
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
                                                        self.startEpisodeList = 50 * index
                                                        self.endEpisodeList = 50 + (50 * index) > episodedata.count ? episodedata.count : 50 + (50 * index)
                                                        self.paginationIndex = index
                                                    }
                                                }
                                            }
                                        }
                                        .frame(maxWidth: 320, alignment: .leading)
                                        .padding(.leading, 20)
                                        .padding(.bottom, 20)
                                    }
                                    .frame(maxWidth: 320, maxHeight: 80)
                                }
                            }
                        }
                        .frame(maxWidth: 320, maxHeight: .infinity)
                        .clipShape(
                            RoundCorner(
                                cornerRadius: 20,
                                maskedCorners: [.topLeft, .bottomLeft]
                            )//OUR CUSTOM SHAPE
                        )
                    }
                }
            }
            .opacity(showUI ? 1.0 : 0.0)
            .animation(.spring(response: 0.3), value: showUI)
        }
    }
}
