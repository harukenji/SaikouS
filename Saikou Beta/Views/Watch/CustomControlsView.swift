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

struct CustomControlsView: View {
    @State var episodeData: StreamData?
    let animeData: InfoData
    var provider: String?
    var episodedata: [Episode]
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
    
    
    var body: some View {
        ZStack {
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
                Color.black.opacity(showUI ? 0.7 : 0.0)
                
                Button(action: {
                    playerVM.isEditingCurrentTime = true
                    playerVM.currentTime += 80
                    playerVM.isEditingCurrentTime = false
                }) {
                    Text("Skip Opening")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(Color(hex: "#8ca7ff"))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.7), lineWidth: 1)
                        )
                }
                .padding(.bottom, 110)
                .padding(.trailing, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(showUI ? 0.1 : 0.0)
            
            ZStack(alignment: .trailing) {
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
                            Image("goBackward")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.white.opacity(0.6))
                                .onTapGesture {
                                    playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime - 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                                    
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
                            
                            Image("goForward")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.white)
                                .onTapGesture {
                                    playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime + 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
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
                    .popup(isPresented: $showingPopup) { // 3
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
                }
                
                ZStack(alignment: .trailing) {
                    Color(.black.withAlphaComponent(0.6))
                        .onTapGesture {
                            showEpisodeSelector = false
                        }
                    VStack {
                        
                        Spacer()
                        
                        ZStack {
                            Color(hex: "#ff16151A")
                                .ignoresSafeArea()
                            VStack(alignment: .leading) {
                                Text("Select Episode")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                ScrollView(.horizontal) {
                                    HStack(spacing: 20) {
                                        ForEach((episodeIndex+1)..<episodedata.count) { index in
                                            ZStack {
                                                AsyncImage(url: URL(string: episodedata[index].image)) { image in
                                                    image.resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 160, height: 90)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                
                                                VStack(alignment: .trailing) {
                                                    Text("\(episodedata[index].number ?? 0)")
                                                        .bold()
                                                        .font(.headline)
                                                        .bold()
                                                        .foregroundColor(.white)
                                                        .padding()
                                                    
                                                    Spacer()
                                                    
                                                    ZStack(alignment: .center) {
                                                        Color(.black)
                                                        
                                                        Text("\(episodedata[index].title ?? "Episode \(episodedata[index].number)")")
                                                            .font(.caption2)
                                                            .bold()
                                                            .lineLimit(2)
                                                            .multilineTextAlignment(.center)
                                                            .foregroundColor(.white)
                                                            .padding(.horizontal, 4)
                                                    }
                                                    .frame(width: 160, height: 50)
                                                }
                                            }
                                            .frame(width: 160, height: 90)
                                            .cornerRadius(12)
                                            .onTapGesture {
                                                Task {
                                                    self.episodeIndex = self.episodeIndex  + index - 1
                                                    
                                                    playerVM.id = self.animeData.id
                                                    playerVM.episodeNumber = episodeIndex
                                                    
                                                    await self.streamApi.loadStream(id: self.episodedata[episodeIndex].id, provider: provider ?? "gogoanime")
                                                    playerVM.setCurrentItem(AVPlayerItem(url: URL(string:  self.streamApi.streamdata?.sources![0].url ?? "/")!))
                                                    playerVM.player.play()
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .frame(width: 440, height: 160)
                        .cornerRadius(20)
                        .padding(.bottom, 60)
                    }
                    .frame(maxHeight: .infinity)
                }
                .opacity(showEpisodeSelector ? 1.0 : 0.0)
                .animation(.spring(response: 0.3), value: showEpisodeSelector)
                
                
                
            }
            .opacity(showUI ? 1.0 : 0.0)
            .animation(.spring(response: 0.3), value: showUI)
        }
    }
}
