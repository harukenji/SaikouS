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
    var viewModel: WatchViewModel
    @StateObject var streamApi = StreamApi()
    @State var doneLoading = false
    @State var showUI: Bool = true
    @State var episodeData: StreamData? = nil
    @State var resIndex: Int = 0
    
    let providerOld = "gogoanime" // or gogoanime
    
    @StateObject private var playerVM = PlayerViewModel()
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var animeEpisodes: FetchedResults<AnimeWatchStorage>
    @FetchRequest(sortDescriptors: []) var userStorageData: FetchedResults<UserStorageInfo>
    
    
    init(animeData: InfoData?, episodeIndex: Int, provider: String?, episodedata: [Episode], viewModel: WatchViewModel) {
        self.animeData = animeData
        self.episodeIndex = episodeIndex
        self.provider = provider
        self.episodedata = episodedata
        self.viewModel = viewModel
        
        print(viewModel.skiptimes)
        
        // we need this to use Picture in Picture
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    @State var access_token: String = ""
    
    func updateAnilistProgress() async {
        if(userStorageData.count > 0) {
            access_token = userStorageData[0].access_token ?? ""
        }
        print(access_token)
        if self.animeData != nil && access_token.count > 0 {
            
            
            let query = """
                    mutation {
                        SaveMediaListEntry( mediaId: \(self.animeData!.id), progress: \(self.episodedata[episodeIndex].number ?? episodeIndex + 1) ) {
                            score(format:POINT_10_DECIMAL) startedAt{year month day} completedAt{year month day}
                        }
                    }
                """
            
            let jsonData = try? JSONSerialization.data(withJSONObject: ["query": query])
            
            let url = URL(string: "https://graphql.anilist.co")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                print("token: ")
                print(access_token)
                print("query: ")
                print(query)
            } catch let error {
                print(error.localizedDescription)
                
            }
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
                                                .frame(width: .infinity, height: .infinity)
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
                                                .frame(width: .infinity, height: .infinity)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    showUI = true
                                                }
                                            
                                            Color.clear
                                                .frame(width: .infinity, height: .infinity)
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
                                    .overlay(CustomControlsView(episodeData: episodeData,animeData: animeData!, episodedata: episodedata, viewModel: viewModel, qualityIndex: resIndex, showUI: $showUI, episodeIndex: episodeIndex, playerVM: playerVM)
                                                , alignment: .bottom)
                            }
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
                        
                        if(playerVM.duration != nil) {
                            var foundEpisode = false
                            for episode in animeEpisodes {
                                if(episode.id != nil && episode.id == self.episodedata[episodeIndex].id) {
                                    if episode.episodeWatched {
                                        foundEpisode = true
                                    } else {
                                        episode.duration = playerVM.duration!
                                        episode.currentTime = playerVM.currentTime
                                        episode.episodeIndex = Int32(episodeIndex)
                                        episode.episodeWatched = playerVM.currentTime / playerVM.duration! >= 0.8
                                        episode.progress = playerVM.currentTime / playerVM.duration!
                                        try? moc.save()
                                        if(playerVM.currentTime / playerVM.duration! >= 0.8) {
                                            Task {
                                                await updateAnilistProgress()
                                            }
                                        }
                                        foundEpisode = true
                                    }
                                }
                            }
                            // if its not in the existing episodes list, create a new entry
                            if !foundEpisode {
                                var episode = AnimeWatchStorage(context: moc)
                                episode.id = self.episodedata[episodeIndex].id
                                episode.duration = playerVM.duration!
                                episode.currentTime = playerVM.currentTime
                                episode.episodeIndex = Int32(episodeIndex)
                                episode.episodeWatched = playerVM.currentTime / playerVM.duration! >= 0.8
                                episode.progress = playerVM.currentTime / playerVM.duration!
                                try? moc.save()
                                if(playerVM.currentTime / playerVM.duration! >= 0.8) {
                                    Task {
                                        await updateAnilistProgress()
                                    }
                                }
                            }
                        }
                        
                        playerVM.player.replaceCurrentItem(with: nil)
                    }
                    .onReceive(playerVM.$currentTime) { newValue in
                        if playerVM.duration != nil && newValue / playerVM.duration! >= 0.8 {
                            // set episode to watched
                            
                            // check if episode exists in CoreData
                            var foundEpisode = false
                            for episode in animeEpisodes {
                                if(episode.id != nil && episode.id == self.episodedata[episodeIndex].id) {
                                    if episode.episodeWatched {
                                        foundEpisode = true
                                    } else {
                                        episode.duration = playerVM.duration!
                                        episode.currentTime = newValue
                                        episode.episodeIndex = Int32(episodeIndex)
                                        episode.episodeWatched = true
                                        episode.progress = newValue / playerVM.duration!
                                        try? moc.save()
                                        Task {
                                            await updateAnilistProgress()
                                        }
                                        foundEpisode = true
                                    }
                                }
                            }
                            // if its not in the existing episodes list, create a new entry
                            if !foundEpisode {
                                var episode = AnimeWatchStorage(context: moc)
                                episode.id = self.episodedata[episodeIndex].id
                                episode.duration = playerVM.duration!
                                episode.currentTime = newValue
                                episode.episodeIndex = Int32(episodeIndex)
                                episode.episodeWatched = true
                                episode.progress = newValue / playerVM.duration!
                                try? moc.save()
                                Task {
                                    await updateAnilistProgress()
                                }
                            }
                        }
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
                                    .frame(maxHeight: .infinity, alignment: .center)
                                    .edgesIgnoringSafeArea(.all)
                                    .ignoresSafeArea(.all)
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
                                    .overlay(CustomControlsView(episodeData: episodeData,animeData: animeData!, episodedata: episodedata, viewModel: viewModel, qualityIndex: resIndex,showUI: $showUI, episodeIndex: episodeIndex, playerVM: playerVM)
                                             , alignment: .bottom)
                            }
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
                                if (self.streamApi.streamdata!.sources![i].quality! == "480p" || self.streamApi.streamdata!.sources![i].quality! == "480") {
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
                        
                        if(playerVM.duration != nil) {
                            var foundEpisode = false
                            for episode in animeEpisodes {
                                if(episode.id != nil && episode.id == self.episodedata[episodeIndex].id) {
                                    if episode.episodeWatched {
                                        foundEpisode = true
                                    } else {
                                        episode.duration = playerVM.duration!
                                        episode.currentTime = playerVM.currentTime
                                        episode.episodeIndex = Int32(episodeIndex)
                                        episode.episodeWatched = playerVM.currentTime / playerVM.duration! >= 0.8
                                        episode.progress = playerVM.currentTime / playerVM.duration!
                                        try? moc.save()
                                        foundEpisode = true
                                    }
                                }
                            }
                            // if its not in the existing episodes list, create a new entry
                            if !foundEpisode {
                                var episode = AnimeWatchStorage(context: moc)
                                episode.duration = playerVM.duration!
                                episode.currentTime = playerVM.currentTime
                                episode.episodeIndex = Int32(episodeIndex)
                                episode.episodeWatched = playerVM.currentTime / playerVM.duration! >= 0.8
                                episode.progress = playerVM.currentTime / playerVM.duration!
                                try? moc.save()
                            }
                        }
                        
                        playerVM.player.replaceCurrentItem(with: nil)
                    }
                    .onReceive(playerVM.$currentTime) { newValue in
                        if playerVM.duration != nil && newValue / playerVM.duration! >= 0.8 {
                            // set episode to watched
                            
                            // check if episode exists in CoreData
                            var foundEpisode = false
                            for episode in animeEpisodes {
                                if(episode.id != nil && episode.id == self.episodedata[episodeIndex].id) {
                                    if episode.episodeWatched {
                                        foundEpisode = true
                                    } else {
                                        episode.duration = playerVM.duration!
                                        episode.currentTime = newValue
                                        episode.episodeIndex = Int32(episodeIndex)
                                        episode.episodeWatched = true
                                        episode.progress = newValue / playerVM.duration!
                                        try? moc.save()
                                        foundEpisode = true
                                    }
                                }
                            }
                            // if its not in the existing episodes list, create a new entry
                            if !foundEpisode {
                                var episode = AnimeWatchStorage(context: moc)
                                episode.duration = playerVM.duration!
                                episode.currentTime = newValue
                                episode.episodeIndex = Int32(episodeIndex)
                                episode.episodeWatched = true
                                episode.progress = newValue / playerVM.duration!
                                try? moc.save()
                            }
                        }
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

