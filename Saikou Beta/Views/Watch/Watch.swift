//
//  WatchPage.swift
//  Inus Stream
//
//  Created by Inumaki on 26.09.22.
//
import SwiftUI
import AVKit
import UIKit
import SwiftUIFontIcon

import Combine
import SwiftWebVTT
import ActivityIndicatorView

final class PlayerViewModel: ObservableObject {
    var player = AVPlayer()
    @Published var isInPipMode: Bool = false
    @Published var isPlaying = false
    
    @Published var isEditingCurrentTime = false
    @Published var currentTime: Double = .zero
    @Published var buffered: Double = .zero
    @Published var duration: Double?
    @Published var selectedSubtitleIndex: Int = 0
    @Published var webVTT: WebVTT?
    @Published var currentSubs: [WebVTT.Cue] = []
    @Published var isLoading: Bool = true
    @Published var hasError: Bool = false
    @Published var id: String = ""
    @Published var episodeNumber: Int = 1
    
    private var subscriptions: Set<AnyCancellable> = []
    private var errorsubscriptions: Set<AnyCancellable> = []
    private var timeObserver: Any?
    private var errorObserver: Any?
    
    deinit {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }
    
    func setVolume(newVolume: Float) {
        player.volume = newVolume
    }
    
    func getVolume() -> Float {
        player.volume
    }
    
    init() {
        $isEditingCurrentTime
            .dropFirst()
            .filter({ $0 == false })
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.player.seek(to: CMTime(seconds: self.currentTime, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                if self.player.rate != 0 {
                    self.player.play()
                }
            })
            .store(in: &subscriptions)
        
        player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    self?.isPlaying = true
                case .paused:
                    self?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            if self.isEditingCurrentTime == false {
                self.currentTime = time.seconds
                self.getSubtitleText()
                
                if(self.player.status == AVPlayer.Status.readyToPlay) {
                    self.isLoading = false} else {self.isLoading = true}
                
                if(self.player.error != nil) {
                    self.hasError = true
                }
            }
        }
        
        player.publisher(for: \.status)
            .sink { [weak self] sts in
                switch sts {
                case .failed:
                    self?.hasError = true
                    print(self?.player.error)
                case .readyToPlay:
                    self?.hasError = false
                case .unknown:
                    self?.hasError = false
                @unknown default:
                    break
                }
            }
            .store(in: &errorsubscriptions)
    }
    
    func getSubtitleText() {
        var new = webVTT?.cues.filter {
            $0.timeStart <= currentTime && $0.timeEnd >= currentTime
        }
        currentSubs = new ?? []
    }
    
    func getCurrentItem() -> AVPlayerItem? {
        return player.currentItem
    }
    
    func setCurrentItem(_ item: AVPlayerItem) {
        currentTime = .zero
        duration = nil
        player.replaceCurrentItem(with: item)
        
        item.publisher(for: \.status)
            .filter({ $0 == .readyToPlay })
            .sink(receiveValue: { [weak self] _ in
                self?.duration = item.asset.duration.seconds
            })
            .store(in: &subscriptions)
    }
}


class PlayerView: UIView {
    
    // Override the property to make AVPlayerLayer the view's backing layer.
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    
    // The associated player object.
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}


struct CustomVideoPlayer: UIViewRepresentable {
    @ObservedObject var playerVM: PlayerViewModel
    @State var showUI: Bool
    
    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.player = playerVM.player
        context.coordinator.setController(view.playerLayer)
        return view
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, AVPictureInPictureControllerDelegate {
        private let parent: CustomVideoPlayer
        private var controller: AVPictureInPictureController?
        private var cancellable: AnyCancellable?
        
        init(_ parent: CustomVideoPlayer) {
            self.parent = parent
            super.init()
            
            cancellable = parent.playerVM.$isInPipMode
                .sink { [weak self] in
                    guard let self = self,
                          let controller = self.controller else { return }
                    if $0 {
                        if controller.isPictureInPictureActive == false {
                            controller.startPictureInPicture()
                        }
                    } else if controller.isPictureInPictureActive {
                        controller.stopPictureInPicture()
                    }
                }
        }
        
        func setController(_ playerLayer: AVPlayerLayer) {
            controller = AVPictureInPictureController(playerLayer: playerLayer)
            controller?.canStartPictureInPictureAutomaticallyFromInline = true
            controller?.delegate = self
        }
        
        func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            parent.playerVM.isInPipMode = true
        }
        
        func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            parent.playerVM.isInPipMode = false
        }
    }
}

struct Media: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    
    var asPlayerItem: AVPlayerItem {
        AVPlayerItem(url: URL(string: url)!)
    }
}

struct UISliderView: UIViewRepresentable {
    @Binding var value: Double
    
    var minValue = 1.0
    var maxValue = 100.0
    var thumbColor: UIColor = .white
    var minTrackColor: UIColor = .blue
    var maxTrackColor: UIColor = .lightGray
    
    class Coordinator: NSObject {
        var value: Binding<Double>
        
        init(value: Binding<Double>) {
            self.value = value
        }
        
        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Double(sender.value)
        }
    }
    
    func makeCoordinator() -> UISliderView.Coordinator {
        Coordinator(value: $value)
    }
    
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.thumbTintColor = thumbColor
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.minimumValue = Float(minValue)
        slider.maximumValue = Float(maxValue)
        slider.value = Float(value)
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = Float(value)
    }
}

struct Subtitle: Equatable {
    let text: String
    let start: CGFloat
    let end: CGFloat
}

enum SettingsNames: Hashable {
    case home
    case subtitle
    case sub_style
    case quality
    case provider
}

enum SubtitleStyle: String, Hashable, CaseIterable {
    case Outlined = "Outlines"
    case Simple = "Simple"
}

extension AnyTransition {
    static var backslide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .trailing))}
}

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
                Color.black.opacity(0.7)
                
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

struct SettingsOption: View {
    let setting_name: String
    let selected_option: String
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 20, maxHeight: 20)
                    .padding(.trailing, 12)
                
                Text("\(setting_name)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(selected_option)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                FontIcon.button(.awesome5Solid(code: .chevron_right), action: {
                    Task {
                        
                    }
                    
                }, fontsize: 14)
                .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: .infinity, height: 40)
        .frame(maxWidth: .infinity, maxHeight: 40)
        .padding(.horizontal, 20)
    }
}

extension View {
    
    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                Popup(
                    isPresented: isPresented,
                    view: view)
            )
        }
}

public struct Popup<PopupContent>: ViewModifier where PopupContent: View {
    
    init(isPresented: Binding<Bool>,
         view: @escaping () -> PopupContent) {
        self._isPresented = isPresented
        self.view = view
    }
    
    /// Controls if the sheet should be presented or not
    @Binding var isPresented: Bool
    
    /// The content to present
    var view: () -> PopupContent
    
    // MARK: - Private Properties
    /// The rect of the hosting controller
    @State private var presenterContentRect: CGRect = .zero
    
    /// The rect of popup content
    @State private var sheetContentRect: CGRect = .zero
    
    /// The offset when the popup is displayed
    private var displayedOffset: CGFloat {
        screenHeight - presenterContentRect.midY - 168
    }
    
    /// The offset when the popup is hidden
    private var hiddenOffset: CGFloat {
        if presenterContentRect.isEmpty {
            return 1000
        }
        return screenHeight - presenterContentRect.midY + sheetContentRect.height/2 + 5
    }
    
    /// The current offset, based on the "presented" property
    private var currentOffset: CGFloat {
        return isPresented ? displayedOffset : hiddenOffset
    }
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.size.width
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.size.height
    }
    
    // MARK: - Content Builders
    public func body(content: Content) -> some View {
        ZStack {
            content
                .frameGetter($presenterContentRect)
        }
        .overlay(sheet())
    }
    
    func sheet() -> some View {
        ZStack {
            self.view()
                .frameGetter($sheetContentRect)
                .frame(width: screenWidth)
                .offset(x: 0, y: currentOffset)
                .animation(Animation.spring(response: 0.3), value: currentOffset)
        }
    }
    
    private func dismiss() {
        isPresented = false
    }
}

extension View {
    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }
}

struct FrameGetter: ViewModifier {
    
    @Binding var frame: CGRect
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    let rect = proxy.frame(in: .global)
                    // This avoids an infinite layout loop
                    if rect.integral != self.frame.integral {
                        DispatchQueue.main.async {
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                })
    }
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

struct StreamData: Codable {
    let headers: header?
    let sources: [source]?
    let subtitles: [subtitle]?
}

struct header: Codable {
    let Referer: String
}

struct source: Codable {
    let url: String
    let isM3U8: Bool
    let quality: String?
}

struct subtitle: Codable {
    let url: String
    let lang: String
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
                            .persistentSystemOverlays(.hidden)
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
                                .persistentSystemOverlays(.hidden)
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
                .persistentSystemOverlays(.hidden)
            } else {
                ZStack {
                    
                    if #available(iOS 16.0, *) {
                        Color(.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                            .ignoresSafeArea(.all)
                            .persistentSystemOverlays(.hidden)
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

struct Loading: View {
    var body: some View {
        ZStack {
            ProgressView()
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
                .navigationBarBackButtonHidden(true)
                .contentShape(Rectangle())
                .ignoresSafeArea(.all)
                .edgesIgnoringSafeArea(.all)
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
