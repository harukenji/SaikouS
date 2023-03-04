//
//  Reader.swift
//  Saikou Beta
//
//  Created by Inumaki on 02.03.23.
//

import SwiftUI
import Kingfisher
import SwiftUIFontIcon

struct mangaImages: Codable {
    let page: Int
    let img: String
}

struct ChapterManager: Codable {
    var previous: [mangaImages]?
    var current: [mangaImages]
    var next: [mangaImages]?
}

struct Reader: View {
    let mangaData: MangaInfoData?
    let provider: String
    @State var selectedChapterIndex: Int
    @State var images: [mangaImages]? = nil
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showUI: Bool = false
    
    
    @State var chapterManager: ChapterManager?
    
    
    func getImages(id: String, provider: String) async -> [mangaImages]? {
        print("https://api.consumet.org/meta/anilist-manga/read?chapterId=\(id)&provider=\(provider)")
        guard let url = URL(string: "https://api.consumet.org/meta/anilist-manga/read?chapterId=\(id)&provider=\(provider)") else {
            //completion(.failure(error: AnilistFetchError.invalidUrlProvided))
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let data = try JSONDecoder().decode([mangaImages].self, from: data)
                return data
                //completion(.success(data: data))
            } catch let error {
                print(error)
                //completion(.failure(error: AnilistFetchError.dataParsingFailed(reason: error)))
            }
            
        } catch let error {
            print(error)
            //completion(.failure(error: AnilistFetchError.dataLoadFailed))
        }
        return nil
    }
    
    @State var offset: CGFloat = 0
    @State var width: CGFloat = 0
    @State var currentPage: Int = 0
    @State var totalPages: Int = 0
    @State var movingOffset: CGFloat = 0
    @State var animationFix: Bool = false
    @State var status: String = "Loading"
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ScrollView(.horizontal) {
                    if(chapterManager != nil) {
                        HStack(spacing: 0) {
                            if(chapterManager!.previous != nil) {
                                HStack(spacing: 0) {
                                    ForEach(0..<chapterManager!.previous!.count, id: \.self) { index in
                                        ZStack {
                                            //Color(hex: "#91A6FF")
                                            Color(.black)
                                            
                                            KFImage(URL(string: chapterManager!.previous![index].img))
                                                .placeholder({ Progress in
                                                    ZStack {
                                                        Circle()
                                                            .stroke(Color.white.opacity(0.4),style: StrokeStyle(lineWidth: 4))
                                                            .rotationEffect(.init(degrees: -90))
                                                            .frame(maxWidth: 60)
                                                            .animation(.linear)
                                                        Circle()
                                                            .trim(from: 0, to: Progress.fractionCompleted)
                                                            .stroke(Color.white,style: StrokeStyle(lineWidth: 4))
                                                            .rotationEffect(.init(degrees: -90))
                                                            .frame(maxWidth: 60)
                                                            .animation(.linear)
                                                    }
                                                })
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                                .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                                        }
                                        .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                    }
                                    if(selectedChapterIndex > 0) {
                                        NextChapterDisplay(currentChapter: "Volume \(mangaData!.chapters![selectedChapterIndex - 1].volumeNumber ?? "0") Chapter \(mangaData!.chapters![selectedChapterIndex - 1].chapterNumber ?? "0")", nextChapter: "Volume \(mangaData!.chapters![selectedChapterIndex].volumeNumber ?? "0") Chapter \(mangaData!.chapters![selectedChapterIndex ].chapterNumber ?? "0")", status: status)
                                            .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                            .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                                    }
                                }
                            }
                            HStack(spacing: 0) {
                                ForEach(0..<chapterManager!.current.count, id: \.self) { index in
                                    ZStack {
                                        //Color(hex: "#91A6FF")
                                        Color(.black)
                                        
                                        KFImage(URL(string: chapterManager!.current[index].img))
                                            .placeholder({ Progress in
                                                ZStack {
                                                    Circle()
                                                        .stroke(Color.white.opacity(0.4),style: StrokeStyle(lineWidth: 4))
                                                        .rotationEffect(.init(degrees: -90))
                                                        .frame(maxWidth: 60)
                                                        .animation(.linear)
                                                    Circle()
                                                        .trim(from: 0, to: Progress.fractionCompleted)
                                                        .stroke(Color.white,style: StrokeStyle(lineWidth: 4))
                                                        .rotationEffect(.init(degrees: -90))
                                                        .frame(maxWidth: 60)
                                                        .animation(.linear)
                                                }
                                            })
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                            .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                                    }
                                    .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                }
                                NextChapterDisplay(currentChapter: "Volume \(mangaData!.chapters![selectedChapterIndex].volumeNumber ?? "0") Chapter \(mangaData!.chapters![selectedChapterIndex].chapterNumber ?? "0")", nextChapter: "Volume \(mangaData!.chapters![selectedChapterIndex + 1].volumeNumber ?? "0") Chapter \(mangaData!.chapters![selectedChapterIndex + 1].chapterNumber ?? "0")", status: status)
                                    .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                    .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                            }
                            if(chapterManager!.next != nil) {
                                HStack(spacing: 0) {
                                    ForEach(0..<chapterManager!.next!.count, id: \.self) { index in
                                        ZStack {
                                            //Color(hex: "#91A6FF")
                                            Color(.black)
                                            
                                            KFImage(URL(string: chapterManager!.next![index].img))
                                                .placeholder({ Progress in
                                                    ZStack {
                                                        Circle()
                                                            .stroke(Color.white.opacity(0.4),style: StrokeStyle(lineWidth: 4))
                                                            .rotationEffect(.init(degrees: -90))
                                                            .frame(maxWidth: 60)
                                                            .animation(.linear)
                                                        Circle()
                                                            .trim(from: 0, to: Progress.fractionCompleted)
                                                            .stroke(Color.white,style: StrokeStyle(lineWidth: 4))
                                                            .rotationEffect(.init(degrees: -90))
                                                            .frame(maxWidth: 60)
                                                            .animation(.linear)
                                                    }
                                                })
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                                .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                                        }
                                        .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                    }
                                    NextChapterDisplay(currentChapter: "Volume \(mangaData!.chapters![selectedChapterIndex + 1].volumeNumber ?? "0") Chapter \(mangaData!.chapters![selectedChapterIndex + 1].chapterNumber ?? "0")", nextChapter: "Volume \(mangaData!.chapters![selectedChapterIndex + 2].volumeNumber ?? "0") Chapter \(mangaData!.chapters![selectedChapterIndex + 2].chapterNumber ?? "0")", status: status)
                                        .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                        .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                                }
                            }
                        }
                        .offset(x: chapterManager!.previous != nil ? (CGFloat(chapterManager!.previous!.count + 1) * -width - offset - movingOffset) : -offset - movingOffset)
                        .animation(animationFix ? nil : .linear)
                    }
                }
                .flipsForRightToLeftLayoutDirection(true)
                .environment(\.layoutDirection, .rightToLeft)
                .disabled(true)
                .onAppear {
                    width = proxy.size.width
                }
                .simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        print(value.translation)
                        movingOffset = value.translation.width
                    })
                        .onEnded({ value in
                            Task {
                                if value.translation.width < 0 {
                                    // left
                                    offset = CGFloat((currentPage - 1)) * width
                                    movingOffset = 0
                                    if(currentPage == 0) {
                                        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
                                        try? await Task.sleep(nanoseconds: 350_000_000)
                                        print("done")
                                        animationFix = true
                                        if(chapterManager != nil) {
                                            if(selectedChapterIndex > 0) {
                                                selectedChapterIndex -= 1
                                                status = "Loading"
                                                
                                                chapterManager!.next = chapterManager!.current
                                                chapterManager!.current = chapterManager!.previous!
                                                
                                                currentPage = chapterManager!.current.count + 1
                                                totalPages = chapterManager!.current.count
                                                offset = CGFloat(chapterManager!.current.count) * width
                                                
                                                if(selectedChapterIndex > 0) {
                                                    
                                                    chapterManager!.previous = await getImages(id: mangaData!.chapters![selectedChapterIndex - 1].id, provider: provider)
                                                    status = "Ready"
                                                } else {
                                                    try? await Task.sleep(nanoseconds: 50_000_000)
                                                }
                                            }
                                        }
                                        animationFix = false
                                    } else {
                                        currentPage -= 1
                                    }
                                }
                                
                                if value.translation.width > 0 {
                                    // right
                                    if(chapterManager != nil && currentPage != chapterManager!.current.count + 1) {
                                        currentPage += 1
                                    }
                                    
                                    offset = CGFloat((currentPage - 1)) * width
                                    movingOffset = 0
                                    if(currentPage == totalPages + 1) {
                                        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
                                        try? await Task.sleep(nanoseconds: 350_000_000)
                                        print("done")
                                        animationFix = true
                                        if(chapterManager != nil && chapterManager!.next != nil) {
                                            if(selectedChapterIndex < mangaData!.chapters!.count - 1) {
                                                selectedChapterIndex += 1
                                                status = "Loading"
                                                
                                                chapterManager!.previous = chapterManager!.current
                                                chapterManager!.current = chapterManager!.next!
                                                
                                                currentPage = 0
                                                totalPages = chapterManager!.current.count
                                                offset = -width
                                                
                                                if(selectedChapterIndex < mangaData!.chapters!.count - 1) {
                                                    chapterManager!.next = await getImages(id: mangaData!.chapters![selectedChapterIndex + 1].id, provider: provider)
                                                    status = "Ready"
                                                }
                                            }
                                            
                                        }
                                        animationFix = false
                                    }
                                }
                            }
                        })
                            .simultaneously(with: TapGesture()
                                .onEnded { _ in
                                    print("VStack tapped")
                                    showUI.toggle()
                                    print(showUI)
                                }))
                
                VStack {
                    ZStack(alignment: .topLeading) {
                        //Rectangle 216
                        Rectangle()
                            .fill(LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex: "#ff000000"), location: 0),
                                        .init(color: Color(hex: "#00000000"), location: 1)]),
                                    startPoint: UnitPoint(x: 0, y: 0),
                                    endPoint: UnitPoint(x: 0, y: 1)))
                            .frame(width: proxy.size.width, height: 215)
                        
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .onTapGesture {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            
                            VStack(alignment: .leading) {
                                Text("Volume \(mangaData != nil && mangaData!.chapters != nil ? (mangaData!.chapters![selectedChapterIndex].volumeNumber ?? "") : "") Chapter \(mangaData != nil && mangaData!.chapters != nil ? (mangaData!.chapters![selectedChapterIndex].chapterNumber ?? "") : "")")
                                    .font(.system(size: 16))
                                    .bold()
                                Text(mangaData != nil ? (mangaData!.title.english ?? mangaData!.title.romaji) : "")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 14))
                                    .bold()
                            }
                            
                            Spacer()
                            
                            FontIcon.button(.awesome5Solid(code: .cog), action: {
                                print("open settings")
                            }, fontsize: 28)
                            .foregroundColor(.white)
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        //Rectangle 216
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(hex: "#00000000"), location: 0),
                                    .init(color: Color(hex: "#ff000000"), location: 1)]),
                                startPoint: UnitPoint(x: 0, y: 0),
                                endPoint: UnitPoint(x: 0, y: 1)))
                            .frame(width: proxy.size.width, height: 215)
                        VStack {
                            CustomReaderSlider(isDragging: .constant(false), currentPage: $currentPage, totalPages: $totalPages, offset: $offset, width: $width,total: 1.0)
                                .frame(maxHeight: 40)
                                .padding(.horizontal, 20)
                                .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                            
                            HStack {
                                Image(systemName: "arrowtriangle.left.circle.fill")
                                    .font(.system(size: 32))
                                    .onTapGesture {
                                        Task {
                                            if(selectedChapterIndex > 0) {
                                                selectedChapterIndex -= 1
                                            }
                                            if(mangaData != nil && mangaData!.chapters != nil) {
                                                await getImages(id: mangaData!.chapters![selectedChapterIndex].id, provider: provider)
                                            }
                                            if(images != nil) {
                                                totalPages = images!.count
                                            }
                                            currentPage = 0
                                        }
                                    }
                                
                                Spacer()
                                
                                Image(systemName: "arrowtriangle.right.circle.fill")
                                    .font(.system(size: 32))
                                    .onTapGesture {
                                        Task {
                                            if(mangaData != nil && mangaData!.chapters != nil) {
                                                if(selectedChapterIndex < mangaData!.chapters!.count) {
                                                    selectedChapterIndex += 1
                                                }
                                                await getImages(id: mangaData!.chapters![selectedChapterIndex].id, provider: provider)
                                            }
                                            if(images != nil) {
                                                totalPages = images!.count
                                            }
                                            currentPage = 0
                                        }
                                    }
                            }
                            .padding(.horizontal, 20)
                            .foregroundColor(Color(hex: "#ff91A6FF"))
                        }
                        
                    }
                }
                .opacity(showUI ? 1.0 : 0.0)
                .animation(.spring(response: 0.3), value: showUI)
                .frame(maxWidth: proxy.size.width, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            Task {
                print(selectedChapterIndex)
                if(mangaData != nil && mangaData!.chapters != nil) {
                    chapterManager = ChapterManager(previous: selectedChapterIndex > 0 ? await getImages(id: mangaData!.chapters![selectedChapterIndex - 1].id, provider: provider) : nil, current: await getImages(id: mangaData!.chapters![selectedChapterIndex].id, provider: provider)!, next: selectedChapterIndex < mangaData!.chapters!.count ? await getImages(id: mangaData!.chapters![selectedChapterIndex + 1].id, provider: provider) : nil)
                }
                if(chapterManager != nil) {
                    totalPages = chapterManager!.current.count
                }
            }
        }
    }
}

struct Reader_Previews: PreviewProvider {
    static var previews: some View {
        Reader(mangaData: nil, provider: "mangadex",selectedChapterIndex: 0)
    }
}

struct CustomReaderSlider: View {
    
    @State private var percentage: Double = 0.0 // or some value binded
    @Binding var isDragging: Bool
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    @Binding var offset: CGFloat
    @Binding var width: CGFloat
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
                            
                            self.currentPage = min(max(1, Int(Double(totalPages) * self.percentage)), totalPages)
                            offset = CGFloat((currentPage - 1)) * width
                            self.isDragging = false
                            self.barHeight = 6
                        })
                            .onChanged({ value in
                                self.isDragging = true
                                self.barHeight = 10
                                print(value)
                                // TODO: - maybe use other logic here
                                self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                                
                                self.currentPage = min(max(1, Int(Double(totalPages) * self.percentage)), totalPages)
                                offset = CGFloat((currentPage - 1)) * width
                            })).animation(.spring(response: 0.3), value: self.isDragging)
                Rectangle()
                    .foregroundColor(Color(hex: "#ff91A6FF"))
                    .frame(width: geometry.size.width * CGFloat(self.percentage / total)).frame(height: barHeight, alignment: .bottom).cornerRadius(12)
                
                
            }.frame(maxHeight: .infinity, alignment: .center)
                .cornerRadius(12)
                .gesture(DragGesture(minimumDistance: 0)
                    .onEnded({ value in
                        self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                        
                        self.currentPage = min(max(1, Int(Double(totalPages) * self.percentage)), totalPages)
                        offset = CGFloat((currentPage - 1)) * width
                        self.isDragging = false
                        self.barHeight = 6
                    })
                        .onChanged({ value in
                            self.isDragging = true
                            self.barHeight = 10
                            print(value)
                            // TODO: - maybe use other logic here
                            self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                            self.currentPage = min(max(1, Int(Double(totalPages) * self.percentage)), totalPages)
                            offset = CGFloat((currentPage - 1)) * width
                        })).animation(.spring(response: 0.3), value: self.isDragging)
            
        }
        .onChange(of: currentPage) { newValue in
            self.percentage = Double(newValue) / Double(totalPages)
        }
    }
}
