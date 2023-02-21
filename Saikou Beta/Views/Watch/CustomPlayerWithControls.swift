//
//  CustomPlayerWithControls.swift
//  Saikou Beta
//
//  Created by Inumaki on 20.02.23.
//

import SwiftUI
import AVKit
import SwiftWebVTT

struct CustomPlayerWithControls: View {
    var animeData: InfoData?
    var episodeIndex: Int
    var provider: String?
    var episodedata: [Episode]
    @StateObject var streamApi = StreamApi()
    @State var doneLoading = false
    @State var showUI: Bool = true
    @State var episodeData: StreamData? = nil
    @State var resIndex: Int = 0
    
    let providerOld = "gogoanime" // or gogoanime
    
    @StateObject private var playerVM = PlayerViewModel()
    
    init(animeData: InfoData?, episodeIndex: Int, provider: String?, episodedata: [Episode]) {
        self.animeData = animeData
        self.episodeIndex = episodeIndex
        self.provider = provider
        self.episodedata = episodedata
        
        // we need this to use Picture in Picture
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    var body: some View {
        if animeData != nil {
            if #available(iOS 16.0, *) {
                ZStack {
                    
                    if #available(iOS 16.0, *) {
                        Color(.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                            .ignoresSafeArea(.all)
                            #if !targetEnvironment(macCatalyst)
                            .persistentSystemOverlays(.hidden)
                            #endif
                    } else {
                        Color(.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                            .ignoresSafeArea(.all)
                    }
                    VStack {
                        VStack {
                            ZStack {
                                CustomVideoPlayer(playerVM: playerVM, showUI: showUI)
                                    .overlay(
                                        HStack {
                                            Color.clear
                                                .frame(width: .infinity, height: 300)
                                                .contentShape(Rectangle())
                                                .gesture(
                                                    TapGesture(count: 2)
                                                        .onEnded({ playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime - 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)})
                                                        .exclusively(before:
                                                                        TapGesture()
                                                            .onEnded({showUI = true})
                                                                    )
                                                )
                                            
                                            Color.clear
                                                .frame(width: .infinity, height: 300)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    showUI = true
                                                }
                                            
                                            Color.clear
                                                .frame(width: .infinity, height: 300)
                                                .contentShape(Rectangle())
                                                .gesture(
                                                    TapGesture(count: 2)
                                                        .onEnded({ playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime + 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)})
                                                        .exclusively(before:
                                                                        TapGesture()
                                                            .onEnded({showUI = true})
                                                                    )
                                                )
                                            
                                        }
                                    )
                                    .overlay(CustomControlsView(episodeData: episodeData,animeData: animeData!, episodedata: episodedata, qualityIndex: resIndex, showUI: $showUI, episodeIndex: episodeIndex, playerVM: playerVM)
                                                , alignment: .bottom)
                            }
                                .padding(.horizontal, 60)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .edgesIgnoringSafeArea(.all)
                                .ignoresSafeArea(.all)
#if !targetEnvironment(macCatalyst)
.persistentSystemOverlays(.hidden)
#endif
                        }
                    }
                    .task {
                        playerVM.episodeNumber = episodeIndex
                        
                        await self.streamApi.loadStream(id: self.episodedata[episodeIndex].id, provider: provider ?? "gogoanime")
                        
                        episodeData = streamApi.streamdata!
                        playerVM.id = self.animeData!.id
                        
                        // get 1080p res
                        
                        if(streamApi.streamdata != nil && streamApi.streamdata!.sources != nil) {
                            for i in 0..<streamApi.streamdata!.sources!.count {
                                if (self.streamApi.streamdata!.sources![i].quality! == "1080p" || self.streamApi.streamdata!.sources![i].quality! == "1080") {
                                    resIndex = i
                                }
                            }
                        }
                        
                        print(episodeData)
                        
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
                        
                        playerVM.setCurrentItem(AVPlayerItem(url:  URL(string: self.streamApi.streamdata?.sources?[resIndex].url ?? "/")!))
                        
                        playerVM.player.play()
                    }
                    .onDisappear {
                        playerVM.player.pause()
                        
                        playerVM.player.replaceCurrentItem(with: nil)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.all)
#if !targetEnvironment(macCatalyst)
.persistentSystemOverlays(.hidden)
#endif
            } else {
                ZStack {
                    
                    if #available(iOS 16.0, *) {
                        Color(.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                            .ignoresSafeArea(.all)
#if !targetEnvironment(macCatalyst)
.persistentSystemOverlays(.hidden)
#endif
                    } else {
                        Color(.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                            .ignoresSafeArea(.all)
                    }
                    VStack {
                        VStack {
                            ZStack {
                                CustomVideoPlayer(playerVM: playerVM, showUI: showUI)
                                    .overlay(
                                        HStack {
                                            Color.clear
                                                .frame(width: .infinity, height: 300)
                                                .contentShape(Rectangle())
                                                .gesture(
                                                    TapGesture(count: 2)
                                                        .onEnded({ playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime - 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)})
                                                        .exclusively(before:
                                                                        TapGesture()
                                                            .onEnded({showUI = true})
                                                                    )
                                                )
                                            
                                            Color.clear
                                                .frame(width: .infinity, height: 300)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    showUI = true
                                                }
                                            
                                            Color.clear
                                                .frame(width: .infinity, height: 300)
                                                .contentShape(Rectangle())
                                                .gesture(
                                                    TapGesture(count: 2)
                                                        .onEnded({ playerVM.player.seek(to: CMTime(seconds: playerVM.currentTime + 15, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)})
                                                        .exclusively(before:
                                                                        TapGesture()
                                                            .onEnded({showUI = true})
                                                                    )
                                                )
                                            
                                        }
                                    )
                                    .overlay(CustomControlsView(episodeData: episodeData,animeData: animeData!, episodedata: episodedata, qualityIndex: resIndex, showUI: $showUI, episodeIndex: episodeIndex, playerVM: playerVM)
                                             , alignment: .bottom)
                            }
                            .padding(.horizontal, 60)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .edgesIgnoringSafeArea(.all)
                            .ignoresSafeArea(.all)
                        }
                    }
                    .task {
                        playerVM.episodeNumber = episodeIndex
                        
                        await self.streamApi.loadStream(id: self.episodedata[episodeIndex].id, provider: provider ?? "gogoanime")
                        
                        episodeData = streamApi.streamdata!
                        playerVM.id = self.animeData!.id
                        
                        // get 1080p res
                        
                        if(streamApi.streamdata != nil && streamApi.streamdata!.sources != nil) {
                            for i in 0..<streamApi.streamdata!.sources!.count {
                                if (self.streamApi.streamdata!.sources![i].quality! == "1080p" || self.streamApi.streamdata!.sources![i].quality! == "1080") {
                                    resIndex = i
                                }
                            }
                        }
                        
                        print(episodeData)
                        
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
                        
                        playerVM.setCurrentItem(AVPlayerItem(url:  URL(string: self.streamApi.streamdata?.sources?[resIndex].url ?? "/")!))
                        
                        playerVM.player.play()
                    }
                    .onDisappear {
                        playerVM.player.pause()
                        
                        playerVM.player.replaceCurrentItem(with: nil)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.all)
            }
        }
        else {
            ZStack {
                Color(.black)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(GaugeProgressStyle())
            }
        }
    }
}

